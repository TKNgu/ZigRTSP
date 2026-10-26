const std = @import("std");
const TcpConnection = @import("tcp_connection.zig").TcpConnection;

pub const request = @import("request.zig");
pub const RequestLine = request.RequestLine;
pub const Request = request.Request;
pub const Method = request.Method;

pub const response = @import("response.zig");
pub const StatusLine = response.StatusLine;
pub const Response = response.Response;
pub const Flags = response.Flags;

pub const parser = @import("parser.zig");
pub const Parser = parser.Parser;

pub const rtp = @import("rtp_response.zig");
pub const RTPResponser = rtp.RTPResponser;
pub const RtpResponse = rtp.RTPResponser;
pub const RtpHeader = rtp.RtpHeader;
pub const IntlHeader = rtp.IntlHeader;

/// Các lỗi phát sinh phía máy khách RTSP
pub const ClientError = error{
    /// Thao tác (PLAY, PAUSE, TEARDOWN, RECORD) yêu cầu Session ID nhưng chưa có
    SessionRequired,
};

/// Máy khách RTSP hỗ trợ gửi toàn bộ các lệnh chuẩn trong RFC 2326 (OPTIONS, DESCRIBE, SETUP, PLAY, PAUSE, TEARDOWN,...)
pub const RtspClient = struct {
    pub const ConnectionInfo = struct {
        host: []const u8,
        port: u16,
        path: []const u8,
    };

    /// Tùy chọn cho yêu cầu DESCRIBE (RFC 2326 Mục 10.2)
    pub const DescribeOptions = struct {
        accept: []const u8 = "application/sdp",
        custom_uri: ?[]const u8 = null,
    };

    /// Tùy chọn cho yêu cầu SETUP (RFC 2326 Mục 10.4)
    pub const SetupOptions = struct {
        /// Cấu hình truyền tải (Bắt buộc theo RFC 2326 Mục 12.39)
        /// Ví dụ: "RTP/AVP/TCP;interleaved=0-1" hoặc "RTP/AVP;unicast;client_port=8000-8001"
        transport: []const u8,
        /// Tên track hoặc URI track cụ thể (ví dụ "trackID=1" hoặc full URL). Nếu null sẽ dùng base_uri.
        track: ?[]const u8 = null,
        /// Session ID (nếu null sẽ tự động dùng session đã lưu trong client)
        session: ?[]const u8 = null,
    };

    /// Tùy chọn cho yêu cầu PLAY (RFC 2326 Mục 10.5)
    pub const PlayOptions = struct {
        session: ?[]const u8 = null,
        /// Khoảng thời gian phát lại (RFC 2326 Mục 12.29 Range), ví dụ: "npt=0-", "npt=10-25"
        range: ?[]const u8 = null,
        /// Tỷ lệ tốc độ phát lại (RFC 2326 Mục 12.34 Scale), ví dụ: "1.0", "2.0"
        scale: ?[]const u8 = null,
        /// Tốc độ truyền tải phân phối dữ liệu (RFC 2326 Mục 12.35 Speed)
        speed: ?[]const u8 = null,
        custom_uri: ?[]const u8 = null,
    };

    /// Tùy chọn cho yêu cầu PAUSE (RFC 2326 Mục 10.6)
    pub const PauseOptions = struct {
        session: ?[]const u8 = null,
        range: ?[]const u8 = null,
        custom_uri: ?[]const u8 = null,
    };

    /// Tùy chọn cho yêu cầu TEARDOWN (RFC 2326 Mục 10.7)
    pub const TeardownOptions = struct {
        session: ?[]const u8 = null,
        custom_uri: ?[]const u8 = null,
    };

    /// Tùy chọn cho yêu cầu GET_PARAMETER (RFC 2326 Mục 10.8)
    pub const GetParameterOptions = struct {
        session: ?[]const u8 = null,
        /// Nội dung/tên tham số cần truy vấn (nếu null sẽ đóng vai trò ping keep-alive rỗng)
        parameter: ?[]const u8 = null,
        content_type: ?[]const u8 = null,
        custom_uri: ?[]const u8 = null,
    };

    /// Tùy chọn cho yêu cầu SET_PARAMETER (RFC 2326 Mục 10.9)
    pub const SetParameterOptions = struct {
        /// Nội dung tham số cần thiết lập (RFC 2326 Mục 10.9)
        body: []const u8,
        content_type: []const u8 = "text/parameters",
        session: ?[]const u8 = null,
        custom_uri: ?[]const u8 = null,
    };

    /// Tùy chọn cho yêu cầu ANNOUNCE (RFC 2326 Mục 10.3)
    pub const AnnounceOptions = struct {
        /// Nội dung bản mô tả phiên SDP cần đăng tải
        sdp: []const u8,
        content_type: []const u8 = "application/sdp",
        session: ?[]const u8 = null,
        custom_uri: ?[]const u8 = null,
    };

    /// Tùy chọn cho yêu cầu RECORD (RFC 2326 Mục 10.11)
    pub const RecordOptions = struct {
        session: ?[]const u8 = null,
        range: ?[]const u8 = null,
        scale: ?[]const u8 = null,
        custom_uri: ?[]const u8 = null,
    };

    pub const Packet = union(enum) {
        response: *Response,
        rtp: *RTPResponser,

        /// In chi tiết nội dung gói tin (RTSP Response hoặc RTP Packet) ra console phục vụ debug
        pub fn dump(self: Packet) void {
            switch (self) {
                .response => |res| res.dump(),
                .rtp => |r| r.dump(),
            }
        }
    };

    /// Cấu trúc Callback nhẹ kết tập phân luồng 2 response: RTSP Response và RTP Packet
    pub const Callback = struct {
        response: *Response,
        rtp: *RTPResponser,
        packet_response: ?Packet = null,

        pub fn init(resp: *Response, rtp_resp: *RTPResponser) Callback {
            return .{
                .response = resp,
                .rtp = rtp_resp,
            };
        }

        // =========================================================================
        // Callbacks phân tích thông điệp RTSP (chuyển tiếp sang Response)
        // =========================================================================
        pub inline fn onStartLine(self: *Callback, chunk: []const u8) !void {
            try self.response.onStartLine(chunk);
        }

        pub inline fn onEndStartLine(self: *Callback) !void {
            try self.response.onEndStartLine();
        }

        pub inline fn onHeaderField(self: *Callback, chunk: []const u8) !void {
            try self.response.onHeaderField(chunk);
        }

        pub inline fn onEndHeaderField(self: *Callback) !void {
            try self.response.onEndHeaderField();
        }

        pub inline fn onHeaderValue(self: *Callback, chunk: []const u8) !void {
            try self.response.onHeaderValue(chunk);
        }

        pub inline fn onEndHeaderValue(self: *Callback) !void {
            try self.response.onEndHeaderValue();
        }

        pub inline fn onHeadersComplete(self: *Callback) !void {
            try self.response.onHeadersComplete();
        }

        pub inline fn onBody(self: *Callback, chunk: []const u8) !void {
            try self.response.onBody(chunk);
        }

        pub inline fn onMessageComplete(self: *Callback) !void {
            self.packet_response = .{
                .response = self.response,
            };
            try self.response.onMessageComplete();
        }

        // =========================================================================
        // Callbacks phân tích khung nhị phân xen kẽ '$' (chuyển tiếp sang RTPResponser)
        // =========================================================================
        pub inline fn onInterleavedBegin(self: *Callback, channel: u8, length: u16) !void {
            try self.rtp.onInterleavedBegin(channel, length);
        }

        pub inline fn onInterleavedData(self: *Callback, channel: u8, chunk: []const u8) !void {
            try self.rtp.onInterleavedData(channel, chunk);
        }

        pub inline fn onInterleavedComplete(self: *Callback, channel: u8) !void {
            self.packet_response = .{
                .rtp = self.rtp,
            };
            try self.rtp.onInterleavedComplete(channel);
        }
    };

    allocator: std.mem.Allocator,
    tcp_connection: TcpConnection,
    rtsp_request: Request,
    base_uri: []const u8,
    session: ?[]const u8 = null,
    user_agent: ?[]const u8 = null,
    debug_enabled: bool = false,

    client_callback: *Callback,
    rtsp_parser: Parser(Callback),
    rtsp_response: *Response,
    rtp_response: *RTPResponser,

    /// Khởi tạo kết nối TCP và cấu hình đối tượng RtspClient
    pub fn init(
        allocator: std.mem.Allocator,
        io: std.Io,
        connection_info: ConnectionInfo,
    ) !RtspClient {
        var tcp_connection = try TcpConnection.init(
            allocator,
            io,
            try std.Io.net.IpAddress.parse(connection_info.host, connection_info.port),
        );
        errdefer tcp_connection.deinit(allocator, io);

        const uri = try std.fmt.allocPrint(
            allocator,
            "rtsp://{s}:{d}/{s}",
            .{ connection_info.host, connection_info.port, connection_info.path },
        );
        errdefer allocator.free(uri);

        var rtsp_request = try request.Request.init(allocator, uri, "RTSP/1.0");
        errdefer rtsp_request.deinit();

        const rtsp_response = try allocator.create(Response);
        errdefer allocator.destroy(rtsp_response);

        rtsp_response.* = Response.init(allocator);
        errdefer rtsp_response.deinit();

        const rtp_response = try allocator.create(RTPResponser);
        errdefer allocator.destroy(rtp_response);

        rtp_response.* = RTPResponser.init(allocator);
        errdefer rtp_response.deinit();

        const client_callback = try allocator.create(Callback);
        errdefer allocator.destroy(client_callback);

        client_callback.* = Callback.init(rtsp_response, rtp_response);

        const rtsp_parser = Parser(Callback).init(client_callback);

        return .{
            .allocator = allocator,
            .tcp_connection = tcp_connection,
            .rtsp_request = rtsp_request,
            .base_uri = uri,
            .session = null,
            .user_agent = null,
            .debug_enabled = false,
            .client_callback = client_callback,
            .rtsp_parser = rtsp_parser,
            .rtsp_response = rtsp_response,
            .rtp_response = rtp_response,
        };
    }

    /// Giải phóng toàn bộ tài nguyên của RtspClient và đóng kết nối TCP
    pub fn deinit(self: *RtspClient, allocator: std.mem.Allocator, io: std.Io) void {
        _ = allocator;
        if (self.session) |s| self.allocator.free(s);
        if (self.user_agent) |ua| self.allocator.free(ua);
        self.allocator.free(self.base_uri);
        self.rtsp_request.deinit();
        self.tcp_connection.deinit(self.allocator, io);
        self.rtsp_response.deinit();
        self.allocator.destroy(self.rtsp_response);
        self.rtp_response.deinit();
        self.allocator.destroy(self.rtp_response);
        self.allocator.destroy(self.client_callback);
    }

    // =========================================================================
    // Quản lý Phiên (Session) & Cấu hình Client
    // =========================================================================

    /// Cập nhật Session ID (thường nhận được từ Header Session trong phản hồi SETUP)
    /// Khi đã đặt, các lệnh sau (PLAY, PAUSE, TEARDOWN,...) sẽ tự động sử dụng Session ID này.
    pub fn setSession(self: *RtspClient, session: []const u8) !void {
        if (self.session) |s| {
            self.allocator.free(s);
        }
        self.session = try self.allocator.dupe(u8, session);
    }

    /// Lấy Session ID hiện tại (nếu có)
    pub fn getSession(self: *const RtspClient) ?[]const u8 {
        return self.session;
    }

    /// Thiết lập chuỗi User-Agent mặc định cho client (tự động đính kèm vào mọi yêu cầu gửi đi)
    pub fn setUserAgent(self: *RtspClient, user_agent: []const u8) !void {
        if (self.user_agent) |ua| {
            self.allocator.free(ua);
        }
        self.user_agent = try self.allocator.dupe(u8, user_agent);
    }

    /// Xây dựng URL đầy đủ cho một track cụ thể hoặc trả về base_uri
    pub fn resolveTrackUri(self: *const RtspClient, track: ?[]const u8) ![]u8 {
        if (track) |t| {
            if (std.mem.startsWith(u8, t, "rtsp://") or std.mem.startsWith(u8, t, "rtsps://")) {
                return try self.allocator.dupe(u8, t);
            }
            if (std.mem.endsWith(u8, self.base_uri, "/")) {
                return try std.fmt.allocPrint(self.allocator, "{s}{s}", .{ self.base_uri, t });
            } else {
                return try std.fmt.allocPrint(self.allocator, "{s}/{s}", .{ self.base_uri, t });
            }
        }
        return try self.allocator.dupe(u8, self.base_uri);
    }

    // =========================================================================
    // Các phương thức gửi yêu cầu RTSP (RFC 2326 Section 10)
    // =========================================================================

    /// Gửi yêu cầu OPTIONS tới máy chủ (RFC 2326 Mục 10.1)
    /// Truy vấn các phương thức và tính năng mà server hỗ trợ.
    pub fn requestOptions(self: *RtspClient) !u32 {
        return try self.requestOptionsWith(null);
    }

    /// Gửi yêu cầu OPTIONS với URI chỉ định (hoặc "*" cho toàn máy chủ)
    pub fn requestOptionsWith(self: *RtspClient, custom_uri: ?[]const u8) !u32 {
        self.rtsp_request.setRequestMethod(.OPTIONS);
        if (custom_uri) |u| {
            try self.rtsp_request.setUri(u);
        }
        return try self.sendRequest();
    }

    /// Gửi yêu cầu DESCRIBE mặc định (RFC 2326 Mục 10.2)
    /// Nhận mô tả bản trình bày đa phương tiện (thường là SDP).
    pub fn requestDescribe(self: *RtspClient) !u32 {
        return try self.requestDescribeWith(.{});
    }

    /// Gửi yêu cầu DESCRIBE với tùy chọn Accept và URI tùy biến
    pub fn requestDescribeWith(self: *RtspClient, options: DescribeOptions) !u32 {
        self.rtsp_request.setRequestMethod(.DESCRIBE);
        if (options.custom_uri) |u| {
            try self.rtsp_request.setUri(u);
        }
        try self.rtsp_request.setAccept(options.accept);
        return try self.sendRequest();
    }

    /// Gửi yêu cầu SETUP (RFC 2326 Mục 10.4)
    /// Thiết lập cơ chế truyền tải luồng media (RTP/RTCP ports hoặc TCP interleaved channels).
    pub fn requestSetup(self: *RtspClient, options: SetupOptions) !u32 {
        self.rtsp_request.setRequestMethod(.SETUP);

        const target_uri = try self.resolveTrackUri(options.track);
        defer self.allocator.free(target_uri);
        try self.rtsp_request.setUri(target_uri);

        try self.rtsp_request.setTransport(options.transport);

        const sess = options.session orelse self.session;
        if (sess) |s| {
            try self.rtsp_request.setSession(s);
        }

        return try self.sendRequest();
    }

    /// Tiện ích khởi tạo nhanh SETUP theo giao thức TCP Interleaved (RFC 2326 Mục 10.12)
    /// Ví dụ: rtp_channel = 0, rtcp_channel = 1 -> "RTP/AVP/TCP;interleaved=0-1"
    pub fn requestSetupTcp(self: *RtspClient, track: ?[]const u8, rtp_channel: u8, rtcp_channel: u8) !u32 {
        var buf: [64]u8 = undefined;
        const transport_str = try std.fmt.bufPrint(&buf, "RTP/AVP/TCP;unicast;interleaved={d}-{d}", .{ rtp_channel, rtcp_channel });
        return try self.requestSetup(.{
            .transport = transport_str,
            .track = track,
        });
    }

    /// Gửi yêu cầu PLAY mặc định (RFC 2326 Mục 10.5)
    pub fn requestPlay(self: *RtspClient) !u32 {
        return try self.requestPlayWith(.{});
    }

    /// Gửi yêu cầu PLAY kèm theo tùy chọn Range, Scale, Session,... (RFC 2326 Mục 10.5)
    pub fn requestPlayWith(self: *RtspClient, options: PlayOptions) !u32 {
        self.rtsp_request.setRequestMethod(.PLAY);

        if (options.custom_uri) |u| {
            try self.rtsp_request.setUri(u);
        }

        const sess = options.session orelse self.session;
        if (sess) |s| {
            try self.rtsp_request.setSession(s);
        }

        if (options.range) |r| {
            try self.rtsp_request.setRange(r);
        }
        if (options.scale) |sc| {
            try self.rtsp_request.setScale(sc);
        }
        if (options.speed) |sp| {
            try self.rtsp_request.setSpeed(sp);
        }

        return try self.sendRequest();
    }

    /// Gửi yêu cầu PAUSE mặc định (RFC 2326 Mục 10.6)
    pub fn requestPause(self: *RtspClient) !u32 {
        return try self.requestPauseWith(.{});
    }

    /// Gửi yêu cầu PAUSE với tùy chọn (RFC 2326 Mục 10.6)
    pub fn requestPauseWith(self: *RtspClient, options: PauseOptions) !u32 {
        self.rtsp_request.setRequestMethod(.PAUSE);

        if (options.custom_uri) |u| {
            try self.rtsp_request.setUri(u);
        }

        const sess = options.session orelse self.session;
        if (sess) |s| {
            try self.rtsp_request.setSession(s);
        }

        if (options.range) |r| {
            try self.rtsp_request.setRange(r);
        }

        return try self.sendRequest();
    }

    /// Gửi yêu cầu TEARDOWN mặc định (RFC 2326 Mục 10.7)
    pub fn requestTeardown(self: *RtspClient) !u32 {
        return try self.requestTeardownWith(.{});
    }

    /// Gửi yêu cầu TEARDOWN với tùy chọn (RFC 2326 Mục 10.7)
    pub fn requestTeardownWith(self: *RtspClient, options: TeardownOptions) !u32 {
        self.rtsp_request.setRequestMethod(.TEARDOWN);

        if (options.custom_uri) |u| {
            try self.rtsp_request.setUri(u);
        }

        const sess = options.session orelse self.session;
        if (sess) |s| {
            try self.rtsp_request.setSession(s);
        }

        const cseq = try self.sendRequest();

        // Xóa Session ID sau khi phiên đã bị hủy
        if (self.session) |s| {
            self.allocator.free(s);
            self.session = null;
        }

        return cseq;
    }

    /// Gửi yêu cầu GET_PARAMETER (RFC 2326 Mục 10.8)
    /// Dùng để truy vấn tham số cấu hình hoặc gửi ping duy trì phiên (keep-alive).
    pub fn requestGetParameter(self: *RtspClient, options: GetParameterOptions) !u32 {
        self.rtsp_request.setRequestMethod(.GET_PARAMETER);

        if (options.custom_uri) |u| {
            try self.rtsp_request.setUri(u);
        }

        const sess = options.session orelse self.session;
        if (sess) |s| {
            try self.rtsp_request.setSession(s);
        }

        if (options.parameter) |param| {
            const ct = options.content_type orelse "text/parameters";
            try self.rtsp_request.addHeaderField("Content-Type", ct);
            try self.rtsp_request.setBody(param);
        }

        return try self.sendRequest();
    }

    /// Gửi yêu cầu ping keep-alive rỗng thông qua GET_PARAMETER (RFC 2326 Mục 10.8)
    pub fn ping(self: *RtspClient) !u32 {
        return try self.requestGetParameter(.{});
    }

    /// Gửi yêu cầu SET_PARAMETER (RFC 2326 Mục 10.9)
    /// Thiết lập giá trị tham số cấu hình cho bản trình diễn hoặc luồng media.
    pub fn requestSetParameter(self: *RtspClient, options: SetParameterOptions) !u32 {
        self.rtsp_request.setRequestMethod(.SET_PARAMETER);

        if (options.custom_uri) |u| {
            try self.rtsp_request.setUri(u);
        }

        const sess = options.session orelse self.session;
        if (sess) |s| {
            try self.rtsp_request.setSession(s);
        }

        try self.rtsp_request.addHeaderField("Content-Type", options.content_type);
        try self.rtsp_request.setBody(options.body);

        return try self.sendRequest();
    }

    /// Gửi yêu cầu ANNOUNCE (RFC 2326 Mục 10.3)
    /// Đăng tải mô tả phương tiện hoặc cập nhật mô tả phiên theo thời gian thực lên server.
    pub fn requestAnnounce(self: *RtspClient, options: AnnounceOptions) !u32 {
        self.rtsp_request.setRequestMethod(.ANNOUNCE);

        if (options.custom_uri) |u| {
            try self.rtsp_request.setUri(u);
        }

        const sess = options.session orelse self.session;
        if (sess) |s| {
            try self.rtsp_request.setSession(s);
        }

        try self.rtsp_request.addHeaderField("Content-Type", options.content_type);
        try self.rtsp_request.setBody(options.sdp);

        return try self.sendRequest();
    }

    /// Gửi yêu cầu RECORD mặc định (RFC 2326 Mục 10.11)
    pub fn requestRecord(self: *RtspClient) !u32 {
        return try self.requestRecordWith(.{});
    }

    /// Gửi yêu cầu RECORD với tùy chọn (RFC 2326 Mục 10.11)
    pub fn requestRecordWith(self: *RtspClient, options: RecordOptions) !u32 {
        self.rtsp_request.setRequestMethod(.RECORD);

        if (options.custom_uri) |u| {
            try self.rtsp_request.setUri(u);
        }

        const sess = options.session orelse self.session;
        if (sess) |s| {
            try self.rtsp_request.setSession(s);
        }

        if (options.range) |r| {
            try self.rtsp_request.setRange(r);
        }
        if (options.scale) |sc| {
            try self.rtsp_request.setScale(sc);
        }

        return try self.sendRequest();
    }

    /// Đọc gói tin kế tiếp bất kể là phản hồi RTSP hay gói tin truyền thông RTP
    pub fn readPacket(self: *RtspClient) !?Packet {
        if (self.client_callback.packet_response) |packet| {
            switch (packet) {
                .response => |tmp| tmp.reset(),
                .rtp => |tmp| tmp.reset(),
            }
            self.client_callback.packet_response = null;
        }
        self.rtsp_parser.unpause();

        var reader = self.tcp_connection.getReader();
        while (true) {
            const buffered = reader.buffered();
            if (buffered.len > 0) {
                const consumed = try self.rtsp_parser.execute(buffered);
                reader.toss(consumed);
                if (self.client_callback.packet_response) |packet| {
                    switch (packet) {
                        .response => |resp| {
                            // Tự động trích xuất và cập nhật Session ID cho phiên làm việc
                            if (resp.getSession()) |sess_header| {
                                const sess_id = if (std.mem.indexOfScalar(u8, sess_header, ';')) |semi|
                                    std.mem.trim(u8, sess_header[0..semi], " \t\r\n")
                                else
                                    std.mem.trim(u8, sess_header, " \t\r\n");
                                if (sess_id.len > 0) {
                                    try self.setSession(sess_id);
                                }
                            }
                        },
                        .rtp => {},
                    }
                    if (self.debug_enabled) {
                        packet.dump();
                    }
                    return packet;
                }
            }
            reader.fillMore() catch |err| switch (err) {
                error.EndOfStream => return null,
                else => return err,
            };
            if (reader.bufferedLen() == 0) {
                return null;
            }
        }
    }

    /// Bật hoặc tắt chế độ debug tự động in các gói tin gửi và nhận
    pub fn setDebug(self: *RtspClient, enabled: bool) void {
        self.debug_enabled = enabled;
    }

    /// In chi tiết yêu cầu RTSP hiện tại ra console
    pub fn dumpRequest(self: *const RtspClient) void {
        self.rtsp_request.dump();
    }

    /// In chi tiết gói tin nhận được (RTSP Response hoặc RTP Packet)
    pub fn dumpPacket(_: *const RtspClient, packet: Packet) void {
        packet.dump();
    }

    /// In chi tiết phản hồi RTSP
    pub fn dumpResponse(_: *const RtspClient, resp: *const Response) void {
        resp.dump();
    }

    /// In chi tiết gói tin RTP/RTCP
    pub fn dumpRtp(_: *const RtspClient, rtp_pkt: *const RTPResponser) void {
        rtp_pkt.dump();
    }

    // =========================================================================
    // Cơ chế gửi Request & Đồng bộ trạng thái nội bộ
    // =========================================================================

    fn sendRequest(self: *RtspClient) !u32 {
        // Tự động đính kèm User-Agent nếu có và request chưa có
        if (self.user_agent) |ua| {
            if (!self.rtsp_request.hasHeaderField("User-Agent")) {
                try self.rtsp_request.setUserAgent(ua);
            }
        }

        if (self.debug_enabled) {
            self.rtsp_request.dump();
        }

        const cesq = try self.rtsp_request.writeAll(&self.tcp_connection.writer.interface);
        try self.tcp_connection.writer.interface.flush();

        // Reset request về trạng thái ban đầu, phục hồi URI về base_uri
        self.rtsp_request.reset();
        try self.rtsp_request.setUri(self.base_uri);
        return cesq;
    }

    fn printRequest(self: *RtspClient) !void {
        self.rtsp_request.dump();
    }
};

// ==========================================
// Unit Tests cho Options & Track Resolution
// ==========================================

test "Track resolution logic" {
    const testing = std.testing;
    const base = "rtsp://10.10.10.119:554/live";

    // Mock client chỉ chứa logic resolution
    const Resolver = struct {
        allocator: std.mem.Allocator,
        base_uri: []const u8,

        pub fn resolveTrackUri(self: *const @This(), track: ?[]const u8) ![]u8 {
            if (track) |t| {
                if (std.mem.startsWith(u8, t, "rtsp://") or std.mem.startsWith(u8, t, "rtsps://")) {
                    return try self.allocator.dupe(u8, t);
                }
                if (std.mem.endsWith(u8, self.base_uri, "/")) {
                    return try std.fmt.allocPrint(self.allocator, "{s}{s}", .{ self.base_uri, t });
                } else {
                    return try std.fmt.allocPrint(self.allocator, "{s}/{s}", .{ self.base_uri, t });
                }
            }
            return try self.allocator.dupe(u8, self.base_uri);
        }
    };

    const resolver = Resolver{ .allocator = testing.allocator, .base_uri = base };

    // Subtrack relative
    const track1 = try resolver.resolveTrackUri("trackID=1");
    defer testing.allocator.free(track1);
    try testing.expectEqualStrings("rtsp://10.10.10.119:554/live/trackID=1", track1);

    // Absolute track
    const track_abs = try resolver.resolveTrackUri("rtsp://10.10.10.119:554/live/audio");
    defer testing.allocator.free(track_abs);
    try testing.expectEqualStrings("rtsp://10.10.10.119:554/live/audio", track_abs);

    // Null track -> base
    const track_null = try resolver.resolveTrackUri(null);
    defer testing.allocator.free(track_null);
    try testing.expectEqualStrings("rtsp://10.10.10.119:554/live", track_null);
}
