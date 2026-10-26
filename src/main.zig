const std = @import("std");
const Io = std.Io;
const rtsp = @import("rtsp/rtsp.zig");
const Parser = @import("rtsp/parser.zig").Parser;
const Response = @import("rtsp/response.zig").Response;

const SERVER = "10.10.10.119";
const PORT = 554;
const PATH = "VT2_485856";

pub fn main(init: std.process.Init) !void {
    var rtsp_client = try rtsp.RtspClient.init(init.gpa, init.io, .{
        .host = SERVER,
        .port = PORT,
        .path = PATH,
    });
    defer rtsp_client.deinit(init.gpa, init.io);

    rtsp_client.setDebug(true);

    var cesq = try rtsp_client.requestDescribe();
    if (try rtsp_client.readPacket()) |packet_response| {
        switch (packet_response) {
            .response => |response| {
                std.debug.print("Request cesq {d} response cesq {}\n", .{ cesq, response.*.cseq });
            },
            .rtp => |rtp| {
                std.debug.print("Rtp packet received\n", .{});
                std.debug.print("Rtp header: {any}\n", .{rtp.header});
                std.debug.print("Rtp payload: {any}\n", .{rtp.payload});
            },
        }
    }

    cesq = try rtsp_client.requestSetupTcp("trackID=0", 0, 1);
    if (try rtsp_client.readPacket()) |packet_response| {
        switch (packet_response) {
            .response => |response| {
                std.debug.print("Request cesq {d} response cesq {}\n", .{ cesq, response.*.cseq });
            },
            .rtp => |rtp| {
                std.debug.print("Rtp packet received\n", .{});
                std.debug.print("Rtp header: {any}\n", .{rtp.header});
                std.debug.print("Rtp payload: {any}\n", .{rtp.payload});
            },
        }
    }

    cesq = try rtsp_client.requestPlay();
    var packet_count: usize = 0;
    while (packet_count < 10) : (packet_count += 1) {
        if (try rtsp_client.readPacket()) |packet_response| {
            switch (packet_response) {
                .response => |response| {
                    std.debug.print("Request cesq {d} response cesq {}\n", .{ cesq, response.*.cseq });
                },
                .rtp => |rtp| {
                    std.debug.print("RTP packet #{d} received: pt={d}, seq={d}, ts={d}, len={d}\n", .{
                        packet_count,
                        rtp.header.payload_type,
                        rtp.header.sequence_number,
                        rtp.header.timestamp,
                        rtp.payload.len,
                    });
                },
            }
        }
    }

    _ = try rtsp_client.requestTeardown();
    if (try rtsp_client.readPacket()) |packet_response| {
        switch (packet_response) {
            .response => |response| {
                std.debug.print("Teardown response cesq {}\n", .{response.*.cseq});
            },
            else => {},
        }
    }
}
