const std = @import("std");
const TcpConnection = @import("tcp_connection.zig").TcpConnection;

pub const request = @import("request.zig");
pub const RequestLine = request.RequestLine;
pub const Request = request.Request;

pub const RtspClient = struct {
    pub const ConnectionInfo = struct {
        host: []const u8,
        port: u16,
        path: []const u8,
    };

    tcp_connection: TcpConnection,
    rtsp_request: Request,

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
        defer allocator.free(uri);

        var rtsp_request = try request.Request.init(allocator, uri, "RTSP/1.0");
        errdefer rtsp_request.deinit();

        return .{
            .tcp_connection = tcp_connection,
            .rtsp_request = rtsp_request,
        };
    }

    pub fn deinit(self: *RtspClient, allocator: std.mem.Allocator, io: std.Io) void {
        self.rtsp_request.deinit();
        self.tcp_connection.deinit(allocator, io);
    }

    pub fn requestOptions(self: *RtspClient) !void {
        self.rtsp_request.setRequestMethod(.OPTIONS);
        try self.sendRequest();
    }

    pub fn requestDescribe(self: *RtspClient) !void {
        self.rtsp_request.setRequestMethod(.DESCRIBE);
        try self.sendRequest();
    }

    fn sendRequest(self: *RtspClient) !void {
        // try self.printRequest();

        try self.rtsp_request.writeAll(&self.tcp_connection.writer.interface);
        try self.tcp_connection.writer.interface.flush();
        self.rtsp_request.reset();
    }

    fn printRequest(self: *RtspClient) !void {
        var buffer_debug: [1024]u8 = undefined;
        var file_writer = std.Io.File.stdout().writer(self.tcp_connection.writer.io, &buffer_debug);
        try self.rtsp_request.writeAll(&file_writer.interface);
        try file_writer.flush();
    }
};
