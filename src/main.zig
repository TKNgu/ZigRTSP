const std = @import("std");
const Io = std.Io;

const SERVER = "127.0.0.1";
const PORT: u16 = 8000;

pub fn main(init: std.process.Init) !void {
    const address = try std.Io.net.IpAddress.parse(SERVER, PORT);
    const stream = try address.connect(init.io, .{
        .mode = .stream,
        .protocol = .tcp,
    });
    defer stream.close(init.io);

    const writer_buffer = try init.gpa.alloc(u8, 1024);
    defer init.gpa.free(writer_buffer);

    var writer = stream.writer(init.io, writer_buffer);
    try writer.interface.writeAll("Hello, world!\n");
    try writer.interface.flush();

    const reader_buffer = try init.gpa.alloc(u8, 1024);
    defer init.gpa.free(reader_buffer);

    var reader = stream.reader(init.io, reader_buffer);
    const buffer = try reader.interface.allocRemaining(init.gpa, std.Io.Limit.limited(1024));
    defer init.gpa.free(buffer);

    std.debug.print("Read ************* {s}\n", .{buffer});
    std.debug.print("Read Size {}\n", .{buffer.len});
}
