const std = @import("std");

/// Các phương thức RTSP được định nghĩa trong RFC 2326 Mục 10 (Method Definitions)
/// và Bảng 2 (Table 2: Overview of RTSP methods).
pub const Method = enum {
    /// DESCRIBE (RFC 2326 Mục 10.2): Lấy thông tin mô tả bản trình bày hoặc luồng media (thường là SDP).
    DESCRIBE,
    /// ANNOUNCE (RFC 2326 Mục 10.3): Đăng tải mô tả phương tiện hoặc cập nhật bản ghi phiên theo thời gian thực.
    ANNOUNCE,
    /// GET_PARAMETER (RFC 2326 Mục 10.8): Lấy giá trị tham số của luồng/bản trình chiếu hoặc dùng kiểm tra kết nối ("ping").
    GET_PARAMETER,
    /// OPTIONS (RFC 2326 Mục 10.1): Truy vấn các phương thức và tùy chọn mà máy chủ hoặc máy khách hỗ trợ.
    OPTIONS,
    /// PAUSE (RFC 2326 Mục 10.6): Tạm dừng phân phối luồng media mà không giải phóng tài nguyên phiên.
    PAUSE,
    /// PLAY (RFC 2326 Mục 10.5): Bắt đầu hoặc tiếp tục truyền dữ liệu luồng theo khoảng Range chỉ định.
    PLAY,
    /// RECORD (RFC 2326 Mục 10.11): Bắt đầu ghi dữ liệu media theo khoảng thời gian chỉ định.
    RECORD,
    /// REDIRECT (RFC 2326 Mục 10.10): Máy chủ thông báo cho máy khách chuyển hướng kết nối sang máy chủ khác.
    REDIRECT,
    /// SETUP (RFC 2326 Mục 10.4): Khởi tạo cơ chế truyền tải (Transport) cho luồng media trước khi phát hoặc ghi.
    SETUP,
    /// SET_PARAMETER (RFC 2326 Mục 10.9): Thiết lập giá trị cho tham số của bản trình bày hoặc luồng media.
    SET_PARAMETER,
    /// TEARDOWN (RFC 2326 Mục 10.7): Kết thúc phiên và giải phóng toàn bộ tài nguyên truyền tải liên quan.
    TEARDOWN,

    /// Chuyển đổi phương thức sang dạng chuỗi đại diện ASCII (RFC 2326 Mục 6.1)
    pub fn toString(self: Method) []const u8 {
        return @tagName(self);
    }
};

/// Dòng yêu cầu đầu tiên của thông điệp RTSP (RFC 2326 Mục 6.1 Request Line).
/// Cú pháp: Request-Line = Method SP Request-URI SP RTSP-Version CRLF
pub const RequestLine = struct {
    /// Phương thức được áp dụng cho tài nguyên (RFC 2326 Mục 6.1 & Mục 10).
    method: Method,
    /// Mã định danh tài nguyên (RFC 2326 Mục 3.2 RTSP URL & Mục 6.1).
    /// Luôn là URL tuyệt đối hoặc "*" (cho OPTIONS).
    uri: []const u8,
    /// Phiên bản giao thức RTSP (RFC 2326 Mục 3.1 & Mục 6.1), ví dụ: "RTSP/1.0".
    version: []const u8,

    /// Ghi Request-Line (Method SP Request-URI SP RTSP-Version) vào writer.
    pub fn writeAll(self: *const RequestLine, writer: *std.Io.Writer) !void {
        try writer.writeAll(self.method.toString());
        try writer.writeAll(" ");
        try writer.writeAll(self.uri);
        try writer.writeAll(" ");
        try writer.writeAll(self.version);
    }
};

/// Cấu trúc đại diện cho thông điệp yêu cầu RTSP từ máy khách tới máy chủ (RFC 2326 Mục 6 Request).
/// Cú pháp: Request = Request-Line *(general-header | request-header | entity-header) CRLF [ message-body ]
pub const Request = struct {
    /// Bộ cấp phát ngoài để quản lý các tài nguyên dài hạn (như chuỗi URI).
    allocator: std.mem.Allocator,
    /// ArenaAllocator để gom và giải phóng nhanh toàn bộ chuỗi tiêu đề (headers) của request.
    arena_allocator: std.heap.ArenaAllocator,
    /// Dòng yêu cầu (RFC 2326 Mục 6.1).
    request_line: RequestLine = undefined,
    /// Số thứ tự lệnh CSeq (RFC 2326 Mục 12.17 & Bảng 3), tự động tăng sau mỗi lần reset.
    cseq: u32 = 1,
    /// Bảng lưu các trường tiêu đề (RFC 2326 Mục 4.2, Mục 5, Mục 6.2, Mục 8.1).
    header_fields: std.hash_map.StringHashMapUnmanaged([]const u8) = .empty,

    /// Khởi tạo một đối tượng yêu cầu RTSP với URI và phiên bản giao thức chỉ định (RFC 2326 Mục 3.1, 3.2, 6.1).
    pub fn init(allocator: std.mem.Allocator, uri: []const u8, version: []const u8) !Request {
        const arena_allocator = std.heap.ArenaAllocator.init(allocator);
        errdefer arena_allocator.deinit();

        const local_uri = try allocator.dupe(u8, uri);
        errdefer allocator.free(local_uri);

        const local_version = try allocator.dupe(u8, version);
        errdefer allocator.free(local_version);

        return .{
            .allocator = allocator,
            .arena_allocator = arena_allocator,
            .request_line = .{
                .method = .OPTIONS,
                .uri = local_uri,
                .version = local_version,
            },
        };
    }

    /// Giải phóng toàn bộ bộ nhớ của request và đóng ArenaAllocator.
    pub fn deinit(self: *Request) void {
        self.header_fields.deinit(self.arena_allocator.allocator());
        self.allocator.free(self.request_line.version);
        self.allocator.free(self.request_line.uri);
        self.arena_allocator.deinit();
    }

    /// Làm mới request để chuẩn bị cho lệnh tiếp theo: xóa headers, reset bộ nhớ arena, và tăng CSeq (RFC 2326 Mục 12.17).
    pub fn reset(self: *Request) void {
        self.header_fields = .empty;
        _ = self.arena_allocator.reset(.retain_capacity);
        self.cseq += 1;
    }

    /// Cập nhật Request-URI (RFC 2326 Mục 3.2).
    /// Thường dùng khi chuyển từ presentation URL sang stream/track URL cụ thể (như trong SETUP).
    pub fn setUri(self: *Request, uri: []const u8) !void {
        self.allocator.free(self.request_line.uri);
        const local_uri = try self.allocator.dupe(u8, uri);
        errdefer self.allocator.free(local_uri);

        self.request_line.uri = local_uri;
    }

    /// Thiết lập phương thức yêu cầu (RFC 2326 Mục 6.1 & Mục 10).
    pub fn setRequestMethod(self: *Request, method: Method) void {
        self.request_line.method = method;
    }

    /// Thêm hoặc cập nhật một trường tiêu đề thông điệp (RFC 2326 Mục 4.2 Message Headers).
    /// Nếu tên tiêu đề là "CSeq", giá trị sẽ được cập nhật trực tiếp vào trường `cseq`.
    pub fn addHeaderField(self: *Request, name: []const u8, value: []const u8) !void {
        if (std.ascii.eqlIgnoreCase(name, "CSeq")) {
            self.cseq = std.fmt.parseInt(u32, value, 10) catch return error.InvalidCSeq;
            return;
        }

        const local_name = try self.arena_allocator.allocator().dupe(u8, name);
        errdefer self.arena_allocator.allocator().free(local_name);

        const local_value = try self.arena_allocator.allocator().dupe(u8, value);
        errdefer self.arena_allocator.allocator().free(local_value);

        _ = try self.header_fields.fetchPut(self.arena_allocator.allocator(), local_name, local_value);
    }

    /// Lấy giá trị của một trường tiêu đề theo tên (nếu tồn tại).
    pub fn getHeaderField(self: *const Request, name: []const u8) ?[]const u8 {
        return self.header_fields.get(name);
    }

    /// Kiểm tra xem một trường tiêu đề đã được thiết lập hay chưa.
    pub fn hasHeaderField(self: *const Request, name: []const u8) bool {
        return self.header_fields.contains(name);
    }

    // =========================================================================
    // General Header Fields (RFC 2326 Section 5 & Table 3)
    // =========================================================================

    /// CSeq: Số thứ tự lệnh (RFC 2326 Mục 12.17)
    pub fn setCSeq(self: *Request, cseq: u32) void {
        self.cseq = cseq;
    }

    /// Cache-Control: Các chỉ thị bộ nhớ đệm (RFC 2326 Mục 12.8)
    /// Ví dụ: "no-cache", "max-age=60", "must-revalidate"
    pub fn setCacheControl(self: *Request, directive: []const u8) !void {
        try self.addHeaderField("Cache-Control", directive);
    }

    /// Connection: Tùy chọn điều khiển kết nối (RFC 2326 Mục 12.10)
    /// Ví dụ: "close"
    pub fn setConnection(self: *Request, connection: []const u8) !void {
        try self.addHeaderField("Connection", connection);
    }

    /// Tiện ích đặt "Connection: close" để đóng kết nối sau khi xử lý xong
    pub fn setConnectionClose(self: *Request) !void {
        try self.setConnection("close");
    }

    /// Date: Dấu thời gian tạo thông điệp theo định dạng HTTP-date (RFC 2326 Mục 12.18)
    /// Ví dụ: "Thu, 23 Jan 1997 15:35:06 GMT"
    pub fn setDate(self: *Request, date: []const u8) !void {
        try self.addHeaderField("Date", date);
    }

    /// Via: Danh sách các giao thức/proxy trung gian (RFC 2326 Mục 12.43)
    /// Ví dụ: "1.0 rtspproxy:554"
    pub fn setVia(self: *Request, via: []const u8) !void {
        try self.addHeaderField("Via", via);
    }

    // =========================================================================
    // Request Header Fields (RFC 2326 Section 6.2 & Table 3)
    // =========================================================================

    /// Accept: Các kiểu nội dung mô tả phiên có thể chấp nhận (RFC 2326 Mục 12.1)
    /// Ví dụ: "application/sdp"
    pub fn setAccept(self: *Request, accept: []const u8) !void {
        try self.addHeaderField("Accept", accept);
    }

    /// Accept-Encoding: Các kiểu mã hóa/nén nội dung chấp nhận được (RFC 2326 Mục 12.2)
    /// Ví dụ: "gzip, deflate"
    pub fn setAcceptEncoding(self: *Request, encoding: []const u8) !void {
        try self.addHeaderField("Accept-Encoding", encoding);
    }

    /// Accept-Language: Ngôn ngữ ưu tiên cho mô tả bản trình bày (RFC 2326 Mục 12.3)
    /// Ví dụ: "en, vi"
    pub fn setAcceptLanguage(self: *Request, language: []const u8) !void {
        try self.addHeaderField("Accept-Language", language);
    }

    /// Authorization: Thông tin xác thực người dùng (RFC 2326 Mục 12.5)
    /// Ví dụ: "Basic YWRtaW46MTIzNDU2" hoặc chuỗi Digest auth
    pub fn setAuthorization(self: *Request, auth: []const u8) !void {
        try self.addHeaderField("Authorization", auth);
    }

    /// From: Địa chỉ email của người dùng điều khiển máy khách (RFC 2326 Mục 12.20)
    /// Ví dụ: "user@example.com"
    pub fn setFrom(self: *Request, from: []const u8) !void {
        try self.addHeaderField("From", from);
    }

    /// If-Modified-Since: Điều kiện cập nhật bản mô tả phiên (RFC 2326 Mục 12.23)
    /// Ví dụ: "Thu, 23 Jan 1997 15:35:06 GMT"
    pub fn setIfModifiedSince(self: *Request, date: []const u8) !void {
        try self.addHeaderField("If-Modified-Since", date);
    }

    /// Range: Khoảng thời gian phát lại hoặc ghi dữ liệu (RFC 2326 Mục 12.29)
    /// Ví dụ: "npt=0-", "npt=10-15", "smpte=0:10:00-0:20:00"
    pub fn setRange(self: *Request, range: []const u8) !void {
        try self.addHeaderField("Range", range);
    }

    /// Referer: URL nguồn dẫn đến yêu cầu tài nguyên hiện tại (RFC 2326 Mục 12.30)
    pub fn setReferer(self: *Request, referer: []const u8) !void {
        try self.addHeaderField("Referer", referer);
    }

    /// User-Agent: Thông tin phần mềm / tác nhân máy khách (RFC 2326 Mục 12.41)
    /// Ví dụ: "ZigRTSP/0.1.0"
    pub fn setUserAgent(self: *Request, user_agent: []const u8) !void {
        try self.addHeaderField("User-Agent", user_agent);
    }

    // --- Các Request Header đặc thù của RTSP (RFC 2326 Bảng 3) ---

    /// Session: Định danh phiên do máy chủ cấp phát (RFC 2326 Mục 12.37)
    /// Bắt buộc cho hầu hết các yêu cầu sau SETUP (PLAY, PAUSE, TEARDOWN, GET_PARAMETER...)
    pub fn setSession(self: *Request, session: []const u8) !void {
        try self.addHeaderField("Session", session);
    }

    /// Transport: Cấu hình truyền tải dữ liệu luồng media (RFC 2326 Mục 12.39)
    /// Bắt buộc cho yêu cầu SETUP. Ví dụ: "RTP/AVP;unicast;client_port=8000-8001"
    pub fn setTransport(self: *Request, transport: []const u8) !void {
        try self.addHeaderField("Transport", transport);
    }

    /// Scale: Tỷ lệ tốc độ phát lại so với thời gian thực (RFC 2326 Mục 12.34)
    /// Ví dụ: "1.0" (chuẩn), "2.0" (tua nhanh x2), "-1.0" (phát lùi)
    pub fn setScale(self: *Request, scale: []const u8) !void {
        try self.addHeaderField("Scale", scale);
    }

    /// Speed: Tốc độ truyền tải dữ liệu phương tiện (RFC 2326 Mục 12.35)
    /// Ví dụ: "1.0", "2.0"
    pub fn setSpeed(self: *Request, speed: []const u8) !void {
        try self.addHeaderField("Speed", speed);
    }

    /// Require: Tùy chọn bắt buộc máy chủ phải hỗ trợ (RFC 2326 Mục 12.32)
    pub fn setRequire(self: *Request, feature: []const u8) !void {
        try self.addHeaderField("Require", feature);
    }

    /// Proxy-Require: Tùy chọn bắt buộc proxy trung gian phải hỗ trợ (RFC 2326 Mục 12.27)
    pub fn setProxyRequire(self: *Request, feature: []const u8) !void {
        try self.addHeaderField("Proxy-Require", feature);
    }

    /// Conference: Mã định danh hội nghị (RFC 2326 Mục 12.9)
    pub fn setConference(self: *Request, conference: []const u8) !void {
        try self.addHeaderField("Conference", conference);
    }

    /// Bandwidth: Băng thông ước tính tối đa của máy khách tính bằng bit/s (RFC 2326 Mục 12.6)
    pub fn setBandwidth(self: *Request, bps: u32) !void {
        var buf: [16]u8 = undefined;
        const str = std.fmt.bufPrint(&buf, "{d}", .{bps}) catch unreachable;
        try self.addHeaderField("Bandwidth", str);
    }

    /// Blocksize: Kích thước gói dữ liệu media mong muốn tính bằng octet (RFC 2326 Mục 12.7)
    pub fn setBlocksize(self: *Request, bytes: u32) !void {
        var buf: [16]u8 = undefined;
        const str = std.fmt.bufPrint(&buf, "{d}", .{bytes}) catch unreachable;
        try self.addHeaderField("Blocksize", str);
    }

    /// Tuần tự hóa toàn bộ thông điệp yêu cầu RTSP ra writer (RFC 2326 Mục 6).
    /// Cấu trúc:
    ///   Request-Line CRLF
    ///   *(header-name ": " header-value CRLF)
    ///   "CSeq: " cseq CRLF
    ///   CRLF
    pub fn writeAll(self: *const Request, writer: *std.Io.Writer) !void {
        try self.request_line.writeAll(writer);
        try writer.writeAll("\r\n");
        var it = self.header_fields.iterator();
        while (it.next()) |entry| {
            try writer.writeAll(entry.key_ptr.*);
            try writer.writeAll(": ");
            try writer.writeAll(entry.value_ptr.*);
            try writer.writeAll("\r\n");
        }
        try self.writeCSeq(writer);
        try writer.writeAll("\r\n");
    }

    /// Ghi tiêu đề CSeq bắt buộc (RFC 2326 Mục 12.17).
    fn writeCSeq(self: *const Request, writer: *std.Io.Writer) !void {
        try writer.writeAll("CSeq: ");
        try writer.print("{d}\r\n", .{self.cseq});
    }
};

test "Request formatting and serialization" {
    const testing = std.testing;
    var req = try Request.init(testing.allocator, "rtsp://10.10.10.119:554/live", "RTSP/1.0");
    defer req.deinit();

    req.setRequestMethod(.DESCRIBE);
    try req.addHeaderField("Accept", "application/sdp");

    var buffer: [512]u8 = undefined;
    var w = std.Io.Writer.fixed(&buffer);
    try req.writeAll(&w);

    const expected = "DESCRIBE rtsp://10.10.10.119:554/live RTSP/1.0\r\nAccept: application/sdp\r\nCSeq: 1\r\n\r\n";
    try testing.expectEqualStrings(expected, w.buffered());

    // Test reset
    req.reset();
    try testing.expectEqual(@as(u32, 2), req.cseq);
    try testing.expectEqual(@as(usize, 0), req.header_fields.count());
}

test "Request setUri" {
    const testing = std.testing;
    var req = try Request.init(testing.allocator, "rtsp://example.com/movie", "RTSP/1.0");
    defer req.deinit();

    try req.setUri("rtsp://example.com/movie/trackID=1");
    try testing.expectEqualStrings("rtsp://example.com/movie/trackID=1", req.request_line.uri);
}

test "Request general headers" {
    const testing = std.testing;
    var req = try Request.init(testing.allocator, "rtsp://10.10.10.119:554/live", "RTSP/1.0");
    defer req.deinit();

    req.setCSeq(42);
    try req.setCacheControl("no-cache");
    try req.setConnectionClose();
    try req.setDate("Fri, 24 Oct 2026 10:30:00 GMT");
    try req.setVia("1.0 rtspproxy:554");

    try testing.expectEqual(@as(u32, 42), req.cseq);
    try testing.expectEqualStrings("no-cache", req.getHeaderField("Cache-Control").?);
    try testing.expectEqualStrings("close", req.getHeaderField("Connection").?);
    try testing.expectEqualStrings("Fri, 24 Oct 2026 10:30:00 GMT", req.getHeaderField("Date").?);
    try testing.expectEqualStrings("1.0 rtspproxy:554", req.getHeaderField("Via").?);

    var buffer: [512]u8 = undefined;
    var w = std.Io.Writer.fixed(&buffer);
    try req.writeAll(&w);

    const out = w.buffered();
    try testing.expect(std.mem.indexOf(u8, out, "CSeq: 42\r\n") != null);
    try testing.expect(std.mem.indexOf(u8, out, "Cache-Control: no-cache\r\n") != null);
    try testing.expect(std.mem.indexOf(u8, out, "Connection: close\r\n") != null);
    try testing.expect(std.mem.indexOf(u8, out, "Date: Fri, 24 Oct 2026 10:30:00 GMT\r\n") != null);
    try testing.expect(std.mem.indexOf(u8, out, "Via: 1.0 rtspproxy:554\r\n") != null);
}

test "Request request headers" {
    const testing = std.testing;
    var req = try Request.init(testing.allocator, "rtsp://example.com/media.mp4", "RTSP/1.0");
    defer req.deinit();

    // Section 6.2 headers
    try req.setAccept("application/sdp");
    try req.setAcceptEncoding("gzip");
    try req.setAcceptLanguage("en-US");
    try req.setAuthorization("Basic YWRtaW46YWRtaW4=");
    try req.setFrom("user@example.com");
    try req.setIfModifiedSince("Fri, 24 Oct 2026 10:30:00 GMT");
    try req.setRange("npt=0-10.5");
    try req.setReferer("http://example.com/index.html");
    try req.setUserAgent("ZigRTSP/0.1.0");

    // Table 3 headers
    try req.setSession("12345678");
    try req.setTransport("RTP/AVP;unicast;client_port=8000-8001");
    try req.setScale("1.0");
    try req.setSpeed("2.0");
    try req.setRequire("implicit-play");
    try req.setProxyRequire("gzipped-messages");
    try req.setConference("conf-001");
    try req.setBandwidth(500000);
    try req.setBlocksize(1400);

    // Assert values
    try testing.expectEqualStrings("application/sdp", req.getHeaderField("Accept").?);
    try testing.expectEqualStrings("gzip", req.getHeaderField("Accept-Encoding").?);
    try testing.expectEqualStrings("en-US", req.getHeaderField("Accept-Language").?);
    try testing.expectEqualStrings("Basic YWRtaW46YWRtaW4=", req.getHeaderField("Authorization").?);
    try testing.expectEqualStrings("user@example.com", req.getHeaderField("From").?);
    try testing.expectEqualStrings("Fri, 24 Oct 2026 10:30:00 GMT", req.getHeaderField("If-Modified-Since").?);
    try testing.expectEqualStrings("npt=0-10.5", req.getHeaderField("Range").?);
    try testing.expectEqualStrings("http://example.com/index.html", req.getHeaderField("Referer").?);
    try testing.expectEqualStrings("ZigRTSP/0.1.0", req.getHeaderField("User-Agent").?);
    try testing.expectEqualStrings("12345678", req.getHeaderField("Session").?);
    try testing.expectEqualStrings("RTP/AVP;unicast;client_port=8000-8001", req.getHeaderField("Transport").?);
    try testing.expectEqualStrings("1.0", req.getHeaderField("Scale").?);
    try testing.expectEqualStrings("2.0", req.getHeaderField("Speed").?);
    try testing.expectEqualStrings("implicit-play", req.getHeaderField("Require").?);
    try testing.expectEqualStrings("gzipped-messages", req.getHeaderField("Proxy-Require").?);
    try testing.expectEqualStrings("conf-001", req.getHeaderField("Conference").?);
    try testing.expectEqualStrings("500000", req.getHeaderField("Bandwidth").?);
    try testing.expectEqualStrings("1400", req.getHeaderField("Blocksize").?);

    var buffer: [2048]u8 = undefined;
    var w = std.Io.Writer.fixed(&buffer);
    try req.writeAll(&w);

    const out = w.buffered();
    try testing.expect(std.mem.indexOf(u8, out, "Accept: application/sdp\r\n") != null);
    try testing.expect(std.mem.indexOf(u8, out, "Session: 12345678\r\n") != null);
    try testing.expect(std.mem.indexOf(u8, out, "Transport: RTP/AVP;unicast;client_port=8000-8001\r\n") != null);
}



