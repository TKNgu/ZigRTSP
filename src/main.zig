const std = @import("std");
const Io = std.Io;
const rtsp = @import("rtsp/rtsp.zig");
const Parser = @import("rtsp/parser.zig").Parser;

const SERVER = "10.10.10.119";
const PORT = 554;
const PATH = "VT2_485856";

pub const Callback = struct {
    allocator: std.mem.Allocator,
    buffer_request_line: std.ArrayList(u8) = .empty,
    buffer_filed: std.ArrayList(u8) = .empty,
    buffer_value: std.ArrayList(u8) = .empty,
    message_offset: usize = 0,
    content_length: usize = 0,
    end: bool = false,

    pub fn init(allocator: std.mem.Allocator) Callback {
        return .{
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Callback, allocator: std.mem.Allocator) void {
        self.buffer_request_line.deinit(allocator);
        self.buffer_filed.deinit(allocator);
        self.buffer_value.deinit(allocator);
    }

    pub fn requestLine(self: *Callback, line: []const u8) !void {
        try self.buffer_request_line.appendSlice(self.allocator, line);
    }
    pub fn endRequestLine(_: *Callback) !void {}

    pub fn headerField(self: *Callback, field: []const u8) !void {
        try self.buffer_filed.appendSlice(self.allocator, field);
    }
    pub fn endHeaderField(_: *Callback) !void {}

    pub fn headerValue(self: *Callback, value: []const u8) !void {
        try self.buffer_value.appendSlice(self.allocator, value);
    }
    pub fn endHeaderValue(self: *Callback) !void {
        if (std.mem.eql(u8, self.buffer_filed.items, "Content-Length")) {
            const buffer = std.mem.trim(u8, self.buffer_value.items, " \t\r\n");
            self.content_length = try std.fmt.parseInt(usize, buffer, 10);
        }
        self.buffer_filed.clearRetainingCapacity();
        self.buffer_value.clearRetainingCapacity();
    }

    pub fn messageBegin(self: *Callback, offset: usize) !void {
        self.message_offset = offset;
        self.end = true;
    }
};

pub fn main(init: std.process.Init) !void {
    var rtsp_client = try rtsp.RtspClient.init(init.gpa, init.io, .{
        .host = SERVER,
        .port = PORT,
        .path = PATH,
    });
    defer rtsp_client.deinit(init.gpa, init.io);

    try rtsp_client.requestDescribe();
    var callback = Callback.init(init.gpa);
    var parser = Parser(Callback).init(&callback);

    var reader = &rtsp_client.tcp_connection.reader.interface;
    try reader.fillMore();
    var buffer: []u8 = undefined;
    while (reader.bufferedLen() > 0) {
        const len = reader.bufferedLen();
        buffer = try reader.take(len);
        try parser.parse(buffer);
        if (callback.end) {
            std.debug.print("Content Length: {d}\n", .{callback.content_length});
            break;
        }
        try reader.fillMore();
    }
    std.debug.print("{s}", .{buffer[callback.message_offset..]});
    try reader.fillMore();
    while (reader.bufferedLen() > 0) {
        buffer = try reader.take(reader.bufferedLen());
        std.debug.print("{s}", .{buffer});
        try reader.fillMore();
    }
}
