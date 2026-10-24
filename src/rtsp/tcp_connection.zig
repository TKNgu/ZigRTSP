const std = @import("std");

pub const TcpConnection = struct {
    stream: std.Io.net.Stream,
    writer: std.Io.net.Stream.Writer,
    reader: std.Io.net.Stream.Reader,

    pub fn init(
        allocator: std.mem.Allocator,
        io: std.Io,
        address: std.Io.net.IpAddress,
    ) !TcpConnection {
        const stream = try address.connect(io, .{
            .mode = .stream,
            .protocol = .tcp,
        });
        errdefer stream.close(io);

        const writer_buffer = try allocator.alloc(u8, 1024);
        errdefer allocator.free(writer_buffer);

        const writer = stream.writer(io, writer_buffer);

        const reader_buffer = try allocator.alloc(u8, 10);
        errdefer allocator.free(reader_buffer);

        const reader = stream.reader(io, reader_buffer);

        return .{
            .stream = stream,
            .writer = writer,
            .reader = reader,
        };
    }

    pub fn deinit(self: *TcpConnection, allocator: std.mem.Allocator, io: std.Io) void {
        allocator.free(self.reader.interface.buffer);
        allocator.free(self.writer.interface.buffer);
        self.stream.close(io);
    }

    pub inline fn gerWriter(self: *TcpConnection) std.Io.Writer {
        return self.writer.interface;
    }

    pub inline fn getReader(self: *TcpConnection) std.Io.Reader {
        return self.reader.interface;
    }
};
