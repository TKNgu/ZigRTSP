const std = @import("std");

/// Dòng trạng thái của thông điệp phản hồi RTSP (RFC 2326 Mục 7.1 Status-Line).
/// Cú pháp: Status-Line = RTSP-Version SP Status-Code SP Reason-Phrase CRLF
pub const StatusLine = struct {
    /// Phiên bản giao thức RTSP (RFC 2326 Mục 3.1 & Mục 7.1), ví dụ: "RTSP/1.0"
    version: []const u8 = "RTSP/1.0",
    /// Mã trạng thái số nguyên 3 chữ số (RFC 2326 Mục 7.1.1 & Bảng 1)
    status_code: u16 = 200,
    /// Cụm từ giải thích ngắn gọn về mã trạng thái (RFC 2326 Mục 7.1.2)
    reason_phrase: []const u8 = "OK",

    /// Ghi Status-Line (Version SP Status-Code SP Reason-Phrase) vào writer
    pub fn writeAll(self: *const StatusLine, writer: *std.Io.Writer) !void {
        try writer.writeAll(self.version);
        try writer.writeAll(" ");
        try writer.print("{d}", .{self.status_code});
        try writer.writeAll(" ");
        try writer.writeAll(self.reason_phrase);
    }
};

/// Tập hợp các cờ trạng thái biểu diễn tiến trình phân tích cú pháp (Staging Flags).
/// Giúp người dùng hoặc parser dễ dàng kiểm tra các mốc hoàn tất của response.
pub const Flags = struct {
    /// Dòng trạng thái (Status-Line) đã được đọc và phân tích thành công
    status_line_complete: bool = false,
    /// Toàn bộ các trường tiêu đề (Headers) đã nhận xong (sau dòng trống CRLF)
    headers_complete: bool = false,
    /// Toàn bộ nội dung body (theo Content-Length) đã nhận xong
    body_complete: bool = false,
    /// Toàn bộ thông điệp response đã hoàn tất
    message_complete: bool = false,

    /// Đặt lại toàn bộ cờ về false
    pub fn reset(self: *Flags) void {
        self.* = .{};
    }
};

/// Cấu trúc đại diện cho thông điệp phản hồi RTSP (RFC 2326 Mục 7 Response).
/// Mô hình thiết kế tương tự Request với:
/// 1. Bộ cấp phát Arena (`arena_allocator`) tái sử dụng tối ưu (`retain_capacity`) mỗi phiên parse.
/// 2. Các cờ trạng thái (`flags`) theo dõi tiến trình.
/// 3. Bảng băm tiêu đề (`header_fields`) hỗ trợ tra cứu case-insensitive.
/// 4. Độ dài nội dung (`content_length`) và bộ đệm body (`body`).
/// 5. Đóng vai trò là Callback trực tiếp cho `Parser(Response)`.
pub const Response = struct {
    /// Bộ cấp phát gốc (Parent allocator, ví dụ GPA)
    allocator: std.mem.Allocator,
    /// Bộ cấp phát Arena để gom và tái sử dụng bộ nhớ cho từng phiên phân tích phản hồi
    arena_allocator: std.heap.ArenaAllocator,

    /// Dòng trạng thái phản hồi (RFC 2326 Mục 7.1)
    status_line: StatusLine = .{},
    /// Số thứ tự lệnh CSeq (RFC 2326 Mục 12.17)
    cseq: u32 = 0,
    /// Bảng lưu các trường tiêu đề (RFC 2326 Mục 4.2, Mục 5, Mục 7.2, Mục 8.1)
    header_fields: std.hash_map.StringHashMapUnmanaged([]const u8) = .empty,

    /// Độ dài phần thân dữ liệu (RFC 2326 Mục 12.14 Content-Length)
    content_length: usize = 0,
    /// Bộ đệm lưu trữ nội dung phần thân thông điệp (ví dụ SDP hoặc dữ liệu tham số)
    body: std.ArrayListUnmanaged(u8) = .empty,

    /// Các cờ trạng thái phân tích
    flags: Flags = .{},

    // Bộ đệm tạm lưu trong arena để tích lũy dữ liệu khi parser phân mảnh TCP
    temp_line: std.ArrayListUnmanaged(u8) = .empty,
    temp_field: std.ArrayListUnmanaged(u8) = .empty,
    temp_value: std.ArrayListUnmanaged(u8) = .empty,

    /// Khởi tạo một đối tượng phản hồi RTSP
    pub fn init(allocator: std.mem.Allocator) Response {
        return .{
            .allocator = allocator,
            .arena_allocator = std.heap.ArenaAllocator.init(allocator),
        };
    }

    /// Giải phóng toàn bộ tài nguyên và đóng ArenaAllocator
    pub fn deinit(self: *Response) void {
        const arena = self.arena_allocator.allocator();
        self.header_fields.deinit(arena);
        self.body.deinit(arena);
        self.temp_line.deinit(arena);
        self.temp_field.deinit(arena);
        self.temp_value.deinit(arena);
        self.arena_allocator.deinit();
    }

    /// Làm mới response để chuẩn bị nhận thông điệp tiếp theo:
    /// - Đặt lại các cờ trạng thái
    /// - Xóa sạch danh sách header, body và các biến tạm
    /// - Tái sử dụng vùng nhớ arena đã cấp phát (`retain_capacity`) để đạt hiệu năng tối đa
    pub fn reset(self: *Response) void {
        self.status_line = .{};
        self.cseq = 0;
        self.header_fields = .empty;
        self.content_length = 0;
        self.body = .empty;
        self.flags.reset();
        self.temp_line = .empty;
        self.temp_field = .empty;
        self.temp_value = .empty;
        _ = self.arena_allocator.reset(.retain_capacity);
    }

    // =========================================================================
    // Trạng thái & Tiện ích kiểm tra (Status Helpers)
    // =========================================================================

    /// Kiểm tra phản hồi có thành công hay không (mã 2xx Success: 200, 201...)
    pub fn isSuccess(self: *const Response) bool {
        return self.status_line.status_code >= 200 and self.status_line.status_code < 300;
    }

    /// Kiểm tra phản hồi chuyển hướng (mã 3xx Redirection)
    pub fn isRedirect(self: *const Response) bool {
        return self.status_line.status_code >= 300 and self.status_line.status_code < 400;
    }

    /// Kiểm tra phản hồi lỗi phía máy khách (mã 4xx Client Error: 400, 401, 404, 454, 461...)
    pub fn isClientError(self: *const Response) bool {
        return self.status_line.status_code >= 400 and self.status_line.status_code < 500;
    }

    /// Kiểm tra phản hồi lỗi phía máy chủ (mã 5xx Server Error: 500, 501, 505...)
    pub fn isServerError(self: *const Response) bool {
        return self.status_line.status_code >= 500 and self.status_line.status_code < 600;
    }

    /// Kiểm tra thông điệp phản hồi đã nhận và phân tích hoàn tất hay chưa
    pub fn isComplete(self: *const Response) bool {
        return self.flags.message_complete;
    }

    /// Lấy lát cắt dữ liệu phần thân thông điệp (Message Body)
    pub fn getBody(self: *const Response) []const u8 {
        return self.body.items;
    }

    // =========================================================================
    // Thao tác với Tiêu đề (Header Management)
    // =========================================================================

    /// Thêm hoặc cập nhật một trường tiêu đề (RFC 2326 Mục 4.2 Message Headers).
    /// Chuỗi được sao chép vào bộ nhớ của `arena_allocator`.
    /// Tự động cập nhật `cseq` nếu tên header là "CSeq" và `content_length` nếu là "Content-Length".
    pub fn addHeaderField(self: *Response, name: []const u8, value: []const u8) !void {
        const trimmed_val = std.mem.trim(u8, value, " \t\r\n");

        if (std.ascii.eqlIgnoreCase(name, "CSeq")) {
            self.cseq = std.fmt.parseInt(u32, trimmed_val, 10) catch 0;
        } else if (std.ascii.eqlIgnoreCase(name, "Content-Length")) {
            self.content_length = std.fmt.parseInt(usize, trimmed_val, 10) catch 0;
        }

        const arena = self.arena_allocator.allocator();
        const local_name = try arena.dupe(u8, name);
        const local_value = try arena.dupe(u8, trimmed_val);

        _ = try self.header_fields.fetchPut(arena, local_name, local_value);
    }

    /// Lấy giá trị của một trường tiêu đề theo tên.
    /// Thực hiện tra cứu nhanh trực tiếp, nếu không thấy sẽ tra cứu không phân biệt hoa thường (RFC 2326 Mục 4.2).
    pub fn getHeaderField(self: *const Response, name: []const u8) ?[]const u8 {
        if (self.header_fields.get(name)) |val| {
            return val;
        }
        var it = self.header_fields.iterator();
        while (it.next()) |entry| {
            if (std.ascii.eqlIgnoreCase(entry.key_ptr.*, name)) {
                return entry.value_ptr.*;
            }
        }
        return null;
    }

    /// Kiểm tra xem một trường tiêu đề đã tồn tại hay chưa
    pub fn hasHeaderField(self: *const Response, name: []const u8) bool {
        return self.getHeaderField(name) != null;
    }

    // =========================================================================
    // Các phương thức tiện ích lấy Header thông dụng (RFC 2326)
    // =========================================================================

    /// CSeq: Số thứ tự lệnh phản hồi (RFC 2326 Mục 12.17)
    pub fn getCSeq(self: *const Response) u32 {
        return self.cseq;
    }

    /// Content-Type: Kiểu MIME của nội dung body, ví dụ "application/sdp" (RFC 2326 Mục 12.16)
    pub fn getContentType(self: *const Response) ?[]const u8 {
        return self.getHeaderField("Content-Type");
    }

    /// Content-Base: URL cơ sở để phân giải URL tương đối trong phần thân (RFC 2326 Mục 12.11)
    pub fn getContentBase(self: *const Response) ?[]const u8 {
        return self.getHeaderField("Content-Base");
    }

    /// Session: Định danh phiên do máy chủ cấp phát (RFC 2326 Mục 12.37)
    pub fn getSession(self: *const Response) ?[]const u8 {
        return self.getHeaderField("Session");
    }

    /// Transport: Cấu hình truyền tải máy chủ chấp nhận (RFC 2326 Mục 12.39)
    pub fn getTransport(self: *const Response) ?[]const u8 {
        return self.getHeaderField("Transport");
    }

    /// Public: Danh sách các phương thức được hỗ trợ (RFC 2326 Mục 12.28 cho OPTIONS)
    pub fn getPublic(self: *const Response) ?[]const u8 {
        return self.getHeaderField("Public");
    }

    /// Server: Tên và phiên bản phần mềm máy chủ (RFC 2326 Mục 12.36)
    pub fn getServer(self: *const Response) ?[]const u8 {
        return self.getHeaderField("Server");
    }

    /// Date: Thời gian tạo phản hồi từ máy chủ (RFC 2326 Mục 12.18)
    pub fn getDate(self: *const Response) ?[]const u8 {
        return self.getHeaderField("Date");
    }

    /// Range: Khoảng thời gian phát lại được máy chủ xác nhận (RFC 2326 Mục 12.29 cho PLAY)
    pub fn getRange(self: *const Response) ?[]const u8 {
        return self.getHeaderField("Range");
    }

    /// RTP-Info: Thông tin đồng bộ RTP cho từng luồng (RFC 2326 Mục 12.33)
    pub fn getRtpInfo(self: *const Response) ?[]const u8 {
        return self.getHeaderField("RTP-Info");
    }

    /// WWW-Authenticate: Thách thức xác thực người dùng nếu mã 401 (RFC 2326 Mục 12.44)
    pub fn getWwwAuthenticate(self: *const Response) ?[]const u8 {
        return self.getHeaderField("WWW-Authenticate");
    }

    // =========================================================================
    // Các phương thức thiết lập dữ liệu (Dành cho việc tạo / serialize Response)
    // =========================================================================

    /// Thiết lập mã trạng thái và cụm từ giải thích (RFC 2326 Mục 7.1)
    pub fn setStatus(self: *Response, code: u16, reason: ?[]const u8) !void {
        const arena = self.arena_allocator.allocator();
        self.status_line.status_code = code;
        if (reason) |r| {
            self.status_line.reason_phrase = try arena.dupe(u8, r);
        } else {
            self.status_line.reason_phrase = defaultReasonPhrase(code);
        }
    }

    /// Thiết lập nội dung phần thân (Body)
    pub fn setBody(self: *Response, data: []const u8) !void {
        const arena = self.arena_allocator.allocator();
        self.body.clearRetainingCapacity();
        try self.body.appendSlice(arena, data);
        self.content_length = data.len;
    }

    /// Thêm dữ liệu vào cuối body
    pub fn appendBody(self: *Response, chunk: []const u8) !void {
        try self.body.appendSlice(self.arena_allocator.allocator(), chunk);
    }

    /// Ghi toàn bộ phản hồi RTSP ra Writer theo chuẩn RFC 2326 Mục 7
    pub fn writeAll(self: *const Response, writer: *std.Io.Writer) !void {
        try self.status_line.writeAll(writer);
        try writer.writeAll("\r\n");

        var it = self.header_fields.iterator();
        while (it.next()) |entry| {
            // Không ghi lại CSeq nếu đã lưu
            if (std.ascii.eqlIgnoreCase(entry.key_ptr.*, "CSeq")) continue;
            if (std.ascii.eqlIgnoreCase(entry.key_ptr.*, "Content-Length")) continue;

            try writer.writeAll(entry.key_ptr.*);
            try writer.writeAll(": ");
            try writer.writeAll(entry.value_ptr.*);
            try writer.writeAll("\r\n");
        }

        if (self.cseq > 0) {
            try writer.print("CSeq: {d}\r\n", .{self.cseq});
        }

        if (self.body.items.len > 0 or self.content_length > 0) {
            const len = if (self.body.items.len > 0) self.body.items.len else self.content_length;
            try writer.print("Content-Length: {d}\r\n", .{len});
        }

        try writer.writeAll("\r\n");

        if (self.body.items.len > 0) {
            try writer.writeAll(self.body.items);
        }
    }

    /// In chi tiết phản hồi RTSP ra console phục vụ debug
    pub fn dump(self: *const Response) void {
        std.debug.print("---------- [RTSP RESPONSE] ----------\n", .{});
        std.debug.print("{s} {d} {s}\n", .{
            self.status_line.version,
            self.status_line.status_code,
            self.status_line.reason_phrase,
        });

        var it = self.header_fields.iterator();
        while (it.next()) |entry| {
            std.debug.print("{s}: {s}\n", .{ entry.key_ptr.*, entry.value_ptr.* });
        }

        if (self.body.items.len > 0) {
            std.debug.print("\n[Body: {d} bytes]\n", .{self.body.items.len});
            std.debug.print("{s}\n", .{self.body.items});
        }
        std.debug.print("-------------------------------------\n", .{});
    }

    // =========================================================================
    // Callbacks phân tích cú pháp (Parser Callbacks - llhttp & legacy)
    // Cho phép truyền trực tiếp con trỏ `*Response` vào `Parser(Response)`.
    // =========================================================================

    /// Phân tích chuỗi dòng trạng thái (Status-Line)
    pub fn parseStatusLine(self: *Response, line: []const u8) !void {
        const trimmed = std.mem.trim(u8, line, " \t\r\n");
        var it = std.mem.splitScalar(u8, trimmed, ' ');
        const arena = self.arena_allocator.allocator();

        if (it.next()) |ver| {
            self.status_line.version = try arena.dupe(u8, ver);
        }
        if (it.next()) |code_str| {
            self.status_line.status_code = std.fmt.parseInt(u16, code_str, 10) catch 0;
        }
        const reason = it.rest();
        if (reason.len > 0) {
            self.status_line.reason_phrase = try arena.dupe(u8, reason);
        } else {
            self.status_line.reason_phrase = defaultReasonPhrase(self.status_line.status_code);
        }
    }

    pub fn onStartLine(self: *Response, chunk: []const u8) !void {
        try self.temp_line.appendSlice(self.arena_allocator.allocator(), chunk);
    }

    pub fn onEndStartLine(self: *Response) !void {
        try self.parseStatusLine(self.temp_line.items);
        self.flags.status_line_complete = true;
        self.temp_line.clearRetainingCapacity();
    }

    pub fn onHeaderField(self: *Response, chunk: []const u8) !void {
        try self.temp_field.appendSlice(self.arena_allocator.allocator(), chunk);
    }

    pub fn onEndHeaderField(_: *Response) !void {}

    pub fn onHeaderValue(self: *Response, chunk: []const u8) !void {
        try self.temp_value.appendSlice(self.arena_allocator.allocator(), chunk);
    }

    pub fn onEndHeaderValue(self: *Response) !void {
        try self.addHeaderField(self.temp_field.items, self.temp_value.items);
        self.temp_field.clearRetainingCapacity();
        self.temp_value.clearRetainingCapacity();
    }

    pub fn onHeadersComplete(self: *Response) !void {
        self.flags.headers_complete = true;
    }

    pub fn onBody(self: *Response, chunk: []const u8) !void {
        try self.body.appendSlice(self.arena_allocator.allocator(), chunk);
    }

    pub fn onMessageComplete(self: *Response) !void {
        self.flags.body_complete = true;
        self.flags.message_complete = true;
    }
};

/// Trả về lý do mặc định cho các mã trạng thái RTSP phổ biến (RFC 2326 Bảng 1)
pub fn defaultReasonPhrase(status_code: u16) []const u8 {
    return switch (status_code) {
        100 => "Continue",
        200 => "OK",
        201 => "Created",
        250 => "Low on Storage Space",
        300 => "Multiple Choices",
        301 => "Moved Permanently",
        302 => "Moved Temporarily",
        303 => "See Other",
        304 => "Not Modified",
        305 => "Use Proxy",
        400 => "Bad Request",
        401 => "Unauthorized",
        402 => "Payment Required",
        403 => "Forbidden",
        404 => "Not Found",
        405 => "Method Not Allowed",
        406 => "Not Acceptable",
        407 => "Proxy Authentication Required",
        408 => "Request Time-out",
        410 => "Gone",
        411 => "Length Required",
        412 => "Precondition Failed",
        413 => "Request Entity Too Large",
        414 => "Request-URI Too Large",
        415 => "Unsupported Media Type",
        451 => "Parameter Not Understood",
        452 => "Conference Not Found",
        453 => "Not Enough Bandwidth",
        454 => "Session Not Found",
        455 => "Method Not Valid in This State",
        456 => "Header Field Not Valid for Resource",
        457 => "Invalid Range",
        458 => "Parameter Is Read-Only",
        459 => "Aggregate Operation Not Allowed",
        460 => "Only Aggregate Operation Allowed",
        461 => "Unsupported Transport",
        462 => "Destination Unreachable",
        500 => "Internal Server Error",
        501 => "Not Implemented",
        502 => "Bad Gateway",
        503 => "Service Unavailable",
        504 => "Gateway Time-out",
        505 => "RTSP Version Not Supported",
        551 => "Option not supported",
        else => "Unknown",
    };
}

// ==========================================
// Unit Tests
// ==========================================

const Parser = @import("parser.zig").Parser;

test "Response init and basic setters" {
    const testing = std.testing;
    var resp = Response.init(testing.allocator);
    defer resp.deinit();

    try resp.setStatus(200, "OK");
    try resp.addHeaderField("CSeq", "1");
    try resp.addHeaderField("Session", "12345678");
    try resp.addHeaderField("Content-Type", "application/sdp");
    try resp.setBody("v=0\r\no=- 0 0 IN IP4 127.0.0.1\r\ns=No Title\r\n");

    try testing.expectEqual(@as(u16, 200), resp.status_line.status_code);
    try testing.expectEqualStrings("OK", resp.status_line.reason_phrase);
    try testing.expectEqual(@as(u32, 1), resp.cseq);
    try testing.expectEqualStrings("12345678", resp.getSession().?);
    try testing.expectEqualStrings("application/sdp", resp.getContentType().?);
    try testing.expect(resp.isSuccess());
    try testing.expect(!resp.isClientError());

    // Kiểm tra serialize
    var buffer: [512]u8 = undefined;
    var w = std.Io.Writer.fixed(&buffer);
    try resp.writeAll(&w);

    const written = w.buffered();
    try testing.expect(std.mem.startsWith(u8, written, "RTSP/1.0 200 OK\r\n"));
    try testing.expect(std.mem.containsAtLeast(u8, written, 1, "CSeq: 1\r\n"));
    try testing.expect(std.mem.containsAtLeast(u8, written, 1, "Session: 12345678\r\n"));
    try testing.expect(std.mem.containsAtLeast(u8, written, 1, "Content-Type: application/sdp\r\n"));
    try testing.expect(std.mem.containsAtLeast(u8, written, 1, "Content-Length: 43\r\n"));
    try testing.expect(std.mem.endsWith(u8, written, "v=0\r\no=- 0 0 IN IP4 127.0.0.1\r\ns=No Title\r\n"));
}

test "Response parsing through Parser" {
    const testing = std.testing;
    var resp = Response.init(testing.allocator);
    defer resp.deinit();

    var parser = Parser(Response).init(&resp);
    const raw =
        "RTSP/1.0 200 OK\r\n" ++
        "CSeq: 1\r\n" ++
        "Public: DESCRIBE, SETUP, TEARDOWN, PLAY, PAUSE\r\n" ++
        "Content-Type: application/sdp\r\n" ++
        "Content-Length: 13\r\n" ++
        "\r\n" ++
        "v=0\r\ns=Live\r\n";

    try parser.parse(raw);

    // Kiểm tra cờ trạng thái
    try testing.expect(resp.flags.status_line_complete);
    try testing.expect(resp.flags.headers_complete);
    try testing.expect(resp.flags.body_complete);
    try testing.expect(resp.flags.message_complete);
    try testing.expect(resp.isComplete());

    // Kiểm tra dữ liệu phân tích
    try testing.expectEqualStrings("RTSP/1.0", resp.status_line.version);
    try testing.expectEqual(@as(u16, 200), resp.status_line.status_code);
    try testing.expectEqualStrings("OK", resp.status_line.reason_phrase);
    try testing.expectEqual(@as(u32, 1), resp.getCSeq());
    try testing.expectEqualStrings("DESCRIBE, SETUP, TEARDOWN, PLAY, PAUSE", resp.getPublic().?);
    try testing.expectEqualStrings("application/sdp", resp.getContentType().?);
    try testing.expectEqual(@as(usize, 13), resp.content_length);
    try testing.expectEqualStrings("v=0\r\ns=Live\r\n", resp.getBody());

    // Kiểm tra case-insensitive header lookup
    try testing.expectEqualStrings("application/sdp", resp.getHeaderField("content-type").?);
    try testing.expectEqualStrings("application/sdp", resp.getHeaderField("CONTENT-TYPE").?);

    // Kiểm tra reset và tái sử dụng arena
    resp.reset();
    parser.reset();

    try testing.expect(!resp.flags.message_complete);
    try testing.expectEqual(@as(usize, 0), resp.content_length);
    try testing.expectEqual(@as(usize, 0), resp.body.items.len);
    try testing.expectEqual(@as(u32, 0), resp.cseq);

    // Parse phản hồi thứ 2 (lỗi 404)
    const raw_err = "RTSP/1.0 404 Not Found\r\nCSeq: 2\r\n\r\n";
    try parser.parse(raw_err);

    try testing.expect(resp.flags.message_complete);
    try testing.expect(!resp.isSuccess());
    try testing.expect(resp.isClientError());
    try testing.expectEqual(@as(u16, 404), resp.status_line.status_code);
    try testing.expectEqualStrings("Not Found", resp.status_line.reason_phrase);
    try testing.expectEqual(@as(u32, 2), resp.getCSeq());
}

test "Response streaming 1-byte at a time" {
    const testing = std.testing;
    var resp = Response.init(testing.allocator);
    defer resp.deinit();

    var parser = Parser(Response).init(&resp);
    const raw = "RTSP/1.0 200 OK\r\nCSeq: 5\r\nContent-Length: 4\r\n\r\nTEST";

    for (raw) |b| {
        try parser.parse(&[_]u8{b});
    }

    try testing.expect(resp.flags.message_complete);
    try testing.expectEqual(@as(u16, 200), resp.status_line.status_code);
    try testing.expectEqual(@as(u32, 5), resp.getCSeq());
    try testing.expectEqual(@as(usize, 4), resp.content_length);
    try testing.expectEqualStrings("TEST", resp.getBody());
}
