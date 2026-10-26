const std = @import("std");

/// Trạng thái của máy trạng thái hữu hạn (FSM) phân tích cú pháp RTSP / HTTP
/// theo mô hình kiến trúc của llhttp.
pub const State = enum {
    start,
    start_line,
    start_line_almost_done,

    header_field_start,
    header_field,
    header_value_discard_ws,
    header_value,
    header_value_almost_done,

    headers_almost_done,

    body,

    // RTSP Interleaved Binary Data (RFC 2326 Section 10.12)
    interleaved_channel,
    interleaved_len_hi,
    interleaved_len_lo,
    interleaved_data,

    message_done,
    dead,
};

/// Kiểu parser (HTTP_BOTH, HTTP_REQUEST, HTTP_RESPONSE theo chuẩn llhttp)
pub const ParserType = enum {
    both,
    request,
    response,
};

/// Các phương thức RTSP 1.0 (RFC 2326) và HTTP thông dụng
pub const Method = enum {
    DESCRIBE,
    ANNOUNCE,
    GET_PARAMETER,
    OPTIONS,
    PAUSE,
    PLAY,
    RECORD,
    REDIRECT,
    SETUP,
    SET_PARAMETER,
    TEARDOWN,
    GET,
    POST,
    PUT,
    DELETE,
    HEAD,
    OTHER,
};

pub const ParserError = error{
    InvalidMethod,
    InvalidVersion,
    InvalidStatusCode,
    InvalidHeaderField,
    InvalidHeaderValue,
    InvalidContentLength,
    InvalidState,
    InvalidCharacter,
    BufferOverflow,
};

/// Nhận diện phương thức RTSP / HTTP từ chuỗi tên phương thức
pub fn parseMethod(str: []const u8) ?Method {
    if (std.mem.eql(u8, str, "DESCRIBE")) return .DESCRIBE;
    if (std.mem.eql(u8, str, "ANNOUNCE")) return .ANNOUNCE;
    if (std.mem.eql(u8, str, "GET_PARAMETER")) return .GET_PARAMETER;
    if (std.mem.eql(u8, str, "OPTIONS")) return .OPTIONS;
    if (std.mem.eql(u8, str, "PAUSE")) return .PAUSE;
    if (std.mem.eql(u8, str, "PLAY")) return .PLAY;
    if (std.mem.eql(u8, str, "RECORD")) return .RECORD;
    if (std.mem.eql(u8, str, "REDIRECT")) return .REDIRECT;
    if (std.mem.eql(u8, str, "SETUP")) return .SETUP;
    if (std.mem.eql(u8, str, "SET_PARAMETER")) return .SET_PARAMETER;
    if (std.mem.eql(u8, str, "TEARDOWN")) return .TEARDOWN;
    if (std.mem.eql(u8, str, "GET")) return .GET;
    if (std.mem.eql(u8, str, "POST")) return .POST;
    if (std.mem.eql(u8, str, "PUT")) return .PUT;
    if (std.mem.eql(u8, str, "DELETE")) return .DELETE;
    if (std.mem.eql(u8, str, "HEAD")) return .HEAD;
    return null;
}

fn isTokenChar(c: u8) bool {
    return switch (c) {
        'a'...'z', 'A'...'Z', '0'...'9',
        '!', '#', '$', '%', '&', '\'', '*', '+', '-', '.', '^', '_', '`', '|', '~',
        => true,
        else => false,
    };
}

fn hasMethod(comptime T: type, comptime name: []const u8) bool {
    if (!@hasDecl(T, name)) return false;
    const decl = @typeInfo(@TypeOf(@field(T, name)));
    return decl == .@"fn";
}

fn methodParamCount(comptime T: type, comptime name: []const u8) usize {
    return @typeInfo(@TypeOf(@field(T, name))).@"fn".params.len;
}

/// RTSP / HTTP Streaming Parser theo mô hình chuẩn của llhttp.
/// - Không cấp phát bộ nhớ động (Zero-allocation).
/// - Khả năng chịu phân mảnh TCP tuyệt đối (Chunk-tolerant, streaming byte-by-byte).
/// - Hỗ trợ phân tích cả Request, Response và RTSP Interleaved binary frame (RFC 2326 Section 10.12).
/// - Tự động nhận diện Content-Length để xác định kích thước body.
/// - Tương thích hoàn toàn với các callback kiểu llhttp mới và callback legacy của ZigRTSP.
pub fn Parser(comptime Callback: type) type {
    return struct {
        const Self = @This();

        callback: *Callback,
        state: State = .start,
        parser_type: ParserType = .both,

        status_code: u16 = 0,
        status_code_stage: enum { start, in_code, done } = .start,
        method: ?Method = null,

        token_buf: [16]u8 = undefined,
        token_len: u8 = 0,
        token_done: bool = false,

        content_length: u64 = 0,
        has_content_length: bool = false,
        body_bytes_read: u64 = 0,

        // RTSP Interleaved binary frame fields ($ + channel + len + data)
        interleaved_channel: u8 = 0,
        interleaved_length: u16 = 0,
        interleaved_bytes_read: u16 = 0,

        // Trạng thái theo dõi Content-Length on-the-fly
        is_content_length: bool = false,
        cl_match_idx: u8 = 0,
        cl_matched: bool = false,

        is_paused: bool = false,

        pub fn init(callback: *Callback) Self {
            return initWithType(callback, .both);
        }

        pub fn initWithType(callback: *Callback, parser_type: ParserType) Self {
            return .{
                .callback = callback,
                .parser_type = parser_type,
            };
        }

        /// Khôi phục toàn bộ trạng thái parser về ban đầu để tái sử dụng connection
        pub fn reset(self: *Self) void {
            self.state = .start;
            self.status_code = 0;
            self.status_code_stage = .start;
            self.method = null;
            self.token_len = 0;
            self.token_done = false;
            self.content_length = 0;
            self.has_content_length = false;
            self.body_bytes_read = 0;
            self.interleaved_channel = 0;
            self.interleaved_length = 0;
            self.interleaved_bytes_read = 0;
            self.is_content_length = false;
            self.cl_match_idx = 0;
            self.cl_matched = false;
            self.is_paused = false;
        }

        /// Tạm dừng quá trình parse
        pub fn pause(self: *Self) void {
            self.is_paused = true;
        }

        /// Tiếp tục quá trình parse
        pub fn @"resume"(self: *Self) void {
            self.is_paused = false;
        }

        pub fn unpause(self: *Self) void {
            self.is_paused = false;
        }

        // ==========================================
        // Callback Notifications (Compile-Time Dispatch)
        // ==========================================

        inline fn notifyMessageBegin(self: *Self) !void {
            if (comptime hasMethod(Callback, "onMessageBegin")) {
                if (comptime methodParamCount(Callback, "onMessageBegin") == 1) {
                    try self.callback.onMessageBegin();
                } else if (comptime methodParamCount(Callback, "onMessageBegin") == 2) {
                    try self.callback.onMessageBegin(self);
                }
            } else if (comptime hasMethod(Callback, "messageBegin") and methodParamCount(Callback, "messageBegin") == 1) {
                try self.callback.messageBegin();
            }
        }

        inline fn notifyStartLine(self: *Self, chunk: []const u8) !void {
            if (chunk.len == 0) return;
            if (comptime hasMethod(Callback, "onStartLine")) {
                try self.callback.onStartLine(chunk);
            } else if (comptime hasMethod(Callback, "requestLine")) {
                try self.callback.requestLine(chunk);
            }
        }

        inline fn notifyEndStartLine(self: *Self) !void {
            if (comptime hasMethod(Callback, "onEndStartLine")) {
                try self.callback.onEndStartLine();
            } else if (comptime hasMethod(Callback, "endRequestLine")) {
                try self.callback.endRequestLine();
            }
        }

        inline fn notifyHeaderField(self: *Self, chunk: []const u8) !void {
            if (chunk.len == 0) return;
            if (comptime hasMethod(Callback, "onHeaderField")) {
                try self.callback.onHeaderField(chunk);
            } else if (comptime hasMethod(Callback, "headerField")) {
                try self.callback.headerField(chunk);
            }
        }

        inline fn notifyEndHeaderField(self: *Self) !void {
            if (comptime hasMethod(Callback, "onEndHeaderField")) {
                try self.callback.onEndHeaderField();
            } else if (comptime hasMethod(Callback, "endHeaderField")) {
                try self.callback.endHeaderField();
            }
        }

        inline fn notifyHeaderValue(self: *Self, chunk: []const u8) !void {
            if (chunk.len == 0) return;
            if (comptime hasMethod(Callback, "onHeaderValue")) {
                try self.callback.onHeaderValue(chunk);
            } else if (comptime hasMethod(Callback, "headerValue")) {
                try self.callback.headerValue(chunk);
            }
        }

        inline fn notifyEndHeaderValue(self: *Self) !void {
            if (comptime hasMethod(Callback, "onEndHeaderValue")) {
                try self.callback.onEndHeaderValue();
            } else if (comptime hasMethod(Callback, "endHeaderValue")) {
                try self.callback.endHeaderValue();
            }
        }

        inline fn notifyHeadersComplete(self: *Self) !void {
            if (comptime hasMethod(Callback, "onHeadersComplete")) {
                if (comptime methodParamCount(Callback, "onHeadersComplete") == 1) {
                    try self.callback.onHeadersComplete();
                } else if (comptime methodParamCount(Callback, "onHeadersComplete") == 2) {
                    try self.callback.onHeadersComplete(self);
                }
            }
        }

        inline fn notifyLegacyMessageBegin(self: *Self, offset: usize) !void {
            if (comptime hasMethod(Callback, "messageBegin") and methodParamCount(Callback, "messageBegin") == 2) {
                try self.callback.messageBegin(offset);
            }
        }

        inline fn notifyBody(self: *Self, chunk: []const u8) !void {
            if (chunk.len == 0) return;
            if (comptime hasMethod(Callback, "onBody")) {
                try self.callback.onBody(chunk);
            } else if (comptime hasMethod(Callback, "body")) {
                try self.callback.body(chunk);
            }
        }

        inline fn notifyMessageComplete(self: *Self) !void {
            if (comptime hasMethod(Callback, "onMessageComplete")) {
                if (comptime methodParamCount(Callback, "onMessageComplete") == 1) {
                    try self.callback.onMessageComplete();
                } else if (comptime methodParamCount(Callback, "onMessageComplete") == 2) {
                    try self.callback.onMessageComplete(self);
                }
            } else if (comptime hasMethod(Callback, "messageComplete")) {
                try self.callback.messageComplete();
            }
        }

        inline fn notifyInterleavedBegin(self: *Self, channel: u8, length: u16) !void {
            if (comptime hasMethod(Callback, "onInterleavedBegin")) {
                try self.callback.onInterleavedBegin(channel, length);
            }
        }

        inline fn notifyInterleavedData(self: *Self, channel: u8, chunk: []const u8) !void {
            if (chunk.len == 0) return;
            if (comptime hasMethod(Callback, "onInterleavedData")) {
                try self.callback.onInterleavedData(channel, chunk);
            } else if (comptime hasMethod(Callback, "onInterleaved")) {
                try self.callback.onInterleaved(channel, chunk);
            }
        }

        inline fn notifyInterleavedComplete(self: *Self, channel: u8) !void {
            if (comptime hasMethod(Callback, "onInterleavedComplete")) {
                try self.callback.onInterleavedComplete(channel);
            }
        }

        /// Hàm tiện ích tương thích với API cũ
        pub fn parse(self: *Self, buffer: []const u8) !void {
            self.unpause();
            _ = try self.execute(buffer);
        }

        /// Hàm thực thi chính theo chuẩn llhttp: phân tích cú pháp stream và trả về số byte đã tiêu thụ
        pub fn execute(self: *Self, buffer: []const u8) !usize {
            if (buffer.len == 0) return 0;
            var p: usize = 0;
            var mark: usize = 0;

            while (p < buffer.len and !self.is_paused) {
                const c = buffer[p];
                switch (self.state) {
                    .start => {
                        if (c == '\r' or c == '\n') {
                            p += 1;
                            continue;
                        } else if (c == '$') {
                            self.state = .interleaved_channel;
                            p += 1;
                            continue;
                        } else if (isTokenChar(c)) {
                            try self.notifyMessageBegin();
                            mark = p;
                            self.token_len = 0;
                            self.token_done = false;
                            self.status_code = 0;
                            self.status_code_stage = .start;
                            self.state = .start_line;
                            // Không tăng p để start_line đọc byte đầu tiên này
                        } else {
                            return error.InvalidCharacter;
                        }
                    },
                    .start_line => {
                        while (p < buffer.len) : (p += 1) {
                            const sc = buffer[p];

                            // Trích xuất method từ token đầu tiên
                            if (!self.token_done) {
                                if (sc == ' ') {
                                    self.token_done = true;
                                    self.method = parseMethod(self.token_buf[0..self.token_len]);
                                } else if (self.token_len < 16) {
                                    self.token_buf[self.token_len] = sc;
                                    self.token_len += 1;
                                }
                            }

                            // Trích xuất status_code nếu là Response (RTSP/1.0 200 OK)
                            if (self.method == null) {
                                switch (self.status_code_stage) {
                                    .start => {
                                        if (sc == ' ') {
                                            self.status_code_stage = .in_code;
                                            self.status_code = 0;
                                        }
                                    },
                                    .in_code => {
                                        if (sc >= '0' and sc <= '9') {
                                            self.status_code = self.status_code * 10 + (sc - '0');
                                        } else {
                                            self.status_code_stage = .done;
                                        }
                                    },
                                    .done => {},
                                }
                            }

                            if (sc == '\r') {
                                try self.notifyStartLine(buffer[mark..p]);
                                self.state = .start_line_almost_done;
                                p += 1;
                                break;
                            } else if (sc == '\n') {
                                try self.notifyStartLine(buffer[mark..p]);
                                try self.notifyEndStartLine();
                                self.state = .header_field_start;
                                p += 1;
                                break;
                            }
                        }
                    },
                    .start_line_almost_done => {
                        if (c == '\n') {
                            try self.notifyEndStartLine();
                            self.state = .header_field_start;
                            p += 1;
                        } else {
                            return error.InvalidCharacter;
                        }
                    },
                    .header_field_start => {
                        if (c == '\r') {
                            self.state = .headers_almost_done;
                            p += 1;
                        } else if (c == '\n') {
                            p += 1;
                            try self.finishHeaders(p);
                            if (comptime hasMethod(Callback, "messageBegin") and methodParamCount(Callback, "messageBegin") == 2 and !hasMethod(Callback, "onBody")) {
                                return p;
                            }
                        } else if (isTokenChar(c)) {
                            self.cl_match_idx = 0;
                            self.cl_matched = true;
                            mark = p;
                            self.state = .header_field;
                        } else {
                            return error.InvalidHeaderField;
                        }
                    },
                    .header_field => {
                        while (p < buffer.len) : (p += 1) {
                            const fc = buffer[p];
                            if (fc == ':') {
                                try self.notifyHeaderField(buffer[mark..p]);
                                try self.notifyEndHeaderField();
                                if (self.cl_matched and self.cl_match_idx == 14) {
                                    self.is_content_length = true;
                                    self.content_length = 0;
                                    self.has_content_length = true;
                                } else {
                                    self.is_content_length = false;
                                }
                                self.state = .header_value_discard_ws;
                                p += 1;
                                break;
                            } else if (isTokenChar(fc)) {
                                if (self.cl_matched) {
                                    if (self.cl_match_idx < 14 and std.ascii.toLower(fc) == "content-length"[self.cl_match_idx]) {
                                        self.cl_match_idx += 1;
                                    } else {
                                        self.cl_matched = false;
                                    }
                                }
                            } else {
                                return error.InvalidHeaderField;
                            }
                        }
                    },
                    .header_value_discard_ws => {
                        while (p < buffer.len) : (p += 1) {
                            const wc = buffer[p];
                            if (wc == ' ' or wc == '\t') {
                                continue;
                            } else if (wc == '\r') {
                                self.state = .header_value_almost_done;
                                p += 1;
                                break;
                            } else if (wc == '\n') {
                                try self.notifyEndHeaderValue();
                                self.is_content_length = false;
                                self.state = .header_field_start;
                                p += 1;
                                break;
                            } else {
                                mark = p;
                                self.state = .header_value;
                                break;
                            }
                        }
                    },
                    .header_value => {
                        while (p < buffer.len) : (p += 1) {
                            const vc = buffer[p];
                            if (vc == '\r') {
                                try self.notifyHeaderValue(buffer[mark..p]);
                                self.state = .header_value_almost_done;
                                p += 1;
                                break;
                            } else if (vc == '\n') {
                                try self.notifyHeaderValue(buffer[mark..p]);
                                try self.notifyEndHeaderValue();
                                self.is_content_length = false;
                                self.state = .header_field_start;
                                p += 1;
                                break;
                            } else {
                                if (self.is_content_length) {
                                    if (vc >= '0' and vc <= '9') {
                                        self.content_length = self.content_length * 10 + (vc - '0');
                                    } else if (vc == ' ' or vc == '\t') {
                                        // Bỏ qua khoảng trắng cuối giá trị trước CRLF
                                    } else {
                                        return error.InvalidContentLength;
                                    }
                                }
                            }
                        }
                    },
                    .header_value_almost_done => {
                        if (c == '\n') {
                            try self.notifyEndHeaderValue();
                            self.is_content_length = false;
                            self.state = .header_field_start;
                            p += 1;
                        } else {
                            return error.InvalidHeaderValue;
                        }
                    },
                    .headers_almost_done => {
                        if (c == '\n') {
                            p += 1;
                            try self.finishHeaders(p);
                            if (comptime hasMethod(Callback, "messageBegin") and methodParamCount(Callback, "messageBegin") == 2 and !hasMethod(Callback, "onBody")) {
                                return p;
                            }
                        } else {
                            return error.InvalidCharacter;
                        }
                    },
                    .body => {
                        const remaining = self.content_length - self.body_bytes_read;
                        const available = buffer.len - p;
                        const to_read = @min(available, remaining);
                        if (to_read > 0) {
                            try self.notifyBody(buffer[p .. p + to_read]);
                            self.body_bytes_read += to_read;
                            p += to_read;
                        }
                        if (self.body_bytes_read == self.content_length) {
                            try self.notifyMessageComplete();
                            self.resetMessageState();
                            self.pause();
                        }
                    },
                    .interleaved_channel => {
                        self.interleaved_channel = c;
                        self.state = .interleaved_len_hi;
                        p += 1;
                    },
                    .interleaved_len_hi => {
                        self.interleaved_length = @as(u16, c) << 8;
                        self.state = .interleaved_len_lo;
                        p += 1;
                    },
                    .interleaved_len_lo => {
                        self.interleaved_length |= c;
                        self.interleaved_bytes_read = 0;
                        try self.notifyInterleavedBegin(self.interleaved_channel, self.interleaved_length);
                        p += 1;
                        if (self.interleaved_length == 0) {
                            try self.notifyInterleavedComplete(self.interleaved_channel);
                            self.state = .start;
                            self.pause();
                        } else {
                            self.state = .interleaved_data;
                        }
                    },
                    .interleaved_data => {
                        const remaining = self.interleaved_length - self.interleaved_bytes_read;
                        const available = buffer.len - p;
                        const to_read = @min(available, remaining);
                        if (to_read > 0) {
                            try self.notifyInterleavedData(self.interleaved_channel, buffer[p .. p + to_read]);
                            self.interleaved_bytes_read += @intCast(to_read);
                            p += to_read;
                        }
                        if (self.interleaved_bytes_read == self.interleaved_length) {
                            try self.notifyInterleavedComplete(self.interleaved_channel);
                            self.state = .start;
                            self.pause();
                        }
                    },
                    .message_done => {
                        self.state = .start;
                    },
                    .dead => {
                        return error.InvalidState;
                    },
                }
            }

            // Gửi các phần token dở dang khi buffer kết thúc giữa chừng
            if (p > mark) {
                switch (self.state) {
                    .start_line => try self.notifyStartLine(buffer[mark..p]),
                    .header_field => try self.notifyHeaderField(buffer[mark..p]),
                    .header_value => try self.notifyHeaderValue(buffer[mark..p]),
                    else => {},
                }
            }

            return p;
        }

        fn finishHeaders(self: *Self, offset: usize) !void {
            if (!self.has_content_length and comptime @hasField(Callback, "content_length")) {
                if (self.callback.content_length > 0) {
                    self.content_length = self.callback.content_length;
                    self.has_content_length = true;
                }
            }

            try self.notifyHeadersComplete();
            try self.notifyLegacyMessageBegin(offset);

            if (self.has_content_length and self.content_length > 0) {
                self.body_bytes_read = 0;
                self.state = .body;
            } else {
                try self.notifyMessageComplete();
                self.resetMessageState();
                self.pause();
            }
        }

        fn resetMessageState(self: *Self) void {
            self.state = .start;
            self.content_length = 0;
            self.has_content_length = false;
            self.body_bytes_read = 0;
            self.is_content_length = false;
        }
    };
}

// ==========================================
// Unit Tests
// ==========================================

const TestCallback = struct {
    allocator: std.mem.Allocator,
    start_line: std.ArrayList(u8) = .empty,
    headers: std.ArrayList(u8) = .empty,
    body: std.ArrayList(u8) = .empty,
    interleaved_data: std.ArrayList(u8) = .empty,
    interleaved_channel: u8 = 0,
    headers_complete_called: bool = false,
    message_complete_called: bool = false,

    pub fn onStartLine(self: *TestCallback, chunk: []const u8) !void {
        try self.start_line.appendSlice(self.allocator, chunk);
    }
    pub fn onEndStartLine(_: *TestCallback) !void {}

    pub fn onHeaderField(self: *TestCallback, chunk: []const u8) !void {
        try self.headers.appendSlice(self.allocator, chunk);
        try self.headers.appendSlice(self.allocator, ": ");
    }
    pub fn onEndHeaderField(_: *TestCallback) !void {}

    pub fn onHeaderValue(self: *TestCallback, chunk: []const u8) !void {
        try self.headers.appendSlice(self.allocator, chunk);
    }
    pub fn onEndHeaderValue(self: *TestCallback) !void {
        try self.headers.appendSlice(self.allocator, "\n");
    }

    pub fn onHeadersComplete(self: *TestCallback) !void {
        self.headers_complete_called = true;
    }

    pub fn onBody(self: *TestCallback, chunk: []const u8) !void {
        try self.body.appendSlice(self.allocator, chunk);
    }

    pub fn onMessageComplete(self: *TestCallback) !void {
        self.message_complete_called = true;
    }

    pub fn onInterleaved(self: *TestCallback, channel: u8, chunk: []const u8) !void {
        self.interleaved_channel = channel;
        try self.interleaved_data.appendSlice(self.allocator, chunk);
    }

    pub fn deinit(self: *TestCallback) void {
        self.start_line.deinit(self.allocator);
        self.headers.deinit(self.allocator);
        self.body.deinit(self.allocator);
        self.interleaved_data.deinit(self.allocator);
    }
};

test "parse complete RTSP response" {
    const allocator = std.testing.allocator;
    var cb = TestCallback{ .allocator = allocator };
    defer cb.deinit();

    var parser = Parser(TestCallback).init(&cb);
    const msg = "RTSP/1.0 200 OK\r\nCSeq: 1\r\nContent-Length: 5\r\n\r\nHello";
    try parser.parse(msg);

    try std.testing.expectEqualStrings("RTSP/1.0 200 OK", cb.start_line.items);
    try std.testing.expectEqual(@as(u16, 200), parser.status_code);
    try std.testing.expect(parser.method == null);
    try std.testing.expect(cb.headers_complete_called);
    try std.testing.expectEqualStrings("Hello", cb.body.items);
    try std.testing.expect(cb.message_complete_called);
}

test "parse 1-byte at a time streaming" {
    const allocator = std.testing.allocator;
    var cb = TestCallback{ .allocator = allocator };
    defer cb.deinit();

    var parser = Parser(TestCallback).init(&cb);
    const msg = "RTSP/1.0 200 OK\r\nCSeq: 2\r\nContent-Length: 4\r\n\r\nTest";
    for (msg) |byte| {
        const slice = &[_]u8{byte};
        try parser.parse(slice);
    }

    try std.testing.expectEqualStrings("RTSP/1.0 200 OK", cb.start_line.items);
    try std.testing.expect(cb.headers_complete_called);
    try std.testing.expectEqualStrings("Test", cb.body.items);
    try std.testing.expect(cb.message_complete_called);
}

test "parse interleaved binary frame" {
    const allocator = std.testing.allocator;
    var cb = TestCallback{ .allocator = allocator };
    defer cb.deinit();

    var parser = Parser(TestCallback).init(&cb);
    // $ + channel 0 + length 4 (0x00, 0x04) + "RTP!"
    const frame = "\x24\x00\x00\x04RTP!";
    try parser.parse(frame);

    try std.testing.expectEqual(0, cb.interleaved_channel);
    try std.testing.expectEqualStrings("RTP!", cb.interleaved_data.items);
}

test "split CRLF across buffers" {
    const allocator = std.testing.allocator;
    var cb = TestCallback{ .allocator = allocator };
    defer cb.deinit();

    var parser = Parser(TestCallback).init(&cb);
    try parser.parse("RTSP/1.0 200 OK\r");
    try parser.parse("\nCSeq: 1\r");
    try parser.parse("\nContent-Length: 0\r");
    try parser.parse("\n\r");
    try parser.parse("\n");

    try std.testing.expectEqualStrings("RTSP/1.0 200 OK", cb.start_line.items);
    try std.testing.expect(cb.headers_complete_called);
    try std.testing.expect(cb.message_complete_called);
}

test "split header name and value across buffers" {
    const allocator = std.testing.allocator;
    var cb = TestCallback{ .allocator = allocator };
    defer cb.deinit();

    var parser = Parser(TestCallback).init(&cb);
    try parser.parse("RTSP/1.0 200 OK\r\nContent-");
    try parser.parse("Length: 3\r\nSession: 987");
    try parser.parse("654\r\n\r\nABC");

    try std.testing.expectEqualStrings("ABC", cb.body.items);
    try std.testing.expect(cb.message_complete_called);
}

test "interleaved frame 1-byte at a time" {
    const allocator = std.testing.allocator;
    var cb = TestCallback{ .allocator = allocator };
    defer cb.deinit();

    var parser = Parser(TestCallback).init(&cb);
    const frame = "\x24\x01\x00\x05World";
    for (frame) |b| {
        try parser.parse(&[_]u8{b});
    }

    try std.testing.expectEqual(1, cb.interleaved_channel);
    try std.testing.expectEqualStrings("World", cb.interleaved_data.items);
}

test "parse RTSP request" {
    const allocator = std.testing.allocator;
    var cb = TestCallback{ .allocator = allocator };
    defer cb.deinit();

    var parser = Parser(TestCallback).init(&cb);
    const req = "DESCRIBE rtsp://10.10.10.119:554/live RTSP/1.0\r\nCSeq: 1\r\nAccept: application/sdp\r\n\r\n";
    try parser.parse(req);

    try std.testing.expectEqualStrings("DESCRIBE rtsp://10.10.10.119:554/live RTSP/1.0", cb.start_line.items);
    try std.testing.expectEqual(Method.DESCRIBE, parser.method.?);
    try std.testing.expectEqual(0, parser.status_code);
    try std.testing.expect(cb.headers_complete_called);
    try std.testing.expect(cb.message_complete_called);
}

const MainCompatCallback = struct {
    allocator: std.mem.Allocator,
    buffer_request_line: std.ArrayList(u8) = .empty,
    buffer_filed: std.ArrayList(u8) = .empty,
    buffer_value: std.ArrayList(u8) = .empty,
    message_offset: usize = 0,
    content_length: usize = 0,
    end: bool = false,

    pub fn requestLine(self: *MainCompatCallback, line: []const u8) !void {
        try self.buffer_request_line.appendSlice(self.allocator, line);
    }
    pub fn endRequestLine(_: *MainCompatCallback) !void {}

    pub fn headerField(self: *MainCompatCallback, field: []const u8) !void {
        try self.buffer_filed.appendSlice(self.allocator, field);
    }
    pub fn endHeaderField(_: *MainCompatCallback) !void {}

    pub fn headerValue(self: *MainCompatCallback, value: []const u8) !void {
        try self.buffer_value.appendSlice(self.allocator, value);
    }
    pub fn endHeaderValue(self: *MainCompatCallback) !void {
        if (std.mem.eql(u8, self.buffer_filed.items, "Content-Length")) {
            const buffer = std.mem.trim(u8, self.buffer_value.items, " \t\r\n");
            self.content_length = try std.fmt.parseInt(usize, buffer, 10);
        }
        self.buffer_filed.clearRetainingCapacity();
        self.buffer_value.clearRetainingCapacity();
    }

    pub fn messageBegin(self: *MainCompatCallback, offset: usize) !void {
        self.message_offset = offset;
        self.end = true;
    }

    pub fn deinit(self: *MainCompatCallback) void {
        self.buffer_request_line.deinit(self.allocator);
        self.buffer_filed.deinit(self.allocator);
        self.buffer_value.deinit(self.allocator);
    }
};

test "main.zig legacy callback compatibility" {
    const allocator = std.testing.allocator;
    var cb = MainCompatCallback{ .allocator = allocator };
    defer cb.deinit();

    var parser = Parser(MainCompatCallback).init(&cb);
    var buffer = "RTSP/1.0 200 OK\r\nCSeq: 1\r\nContent-Length: 5\r\n\r\nHello".*;
    try parser.parse(&buffer);

    try std.testing.expect(cb.end);
    try std.testing.expectEqual(5, cb.content_length);
    try std.testing.expectEqualStrings("RTSP/1.0 200 OK", cb.buffer_request_line.items);
    try std.testing.expectEqualStrings("Hello", buffer[cb.message_offset..]);
}
