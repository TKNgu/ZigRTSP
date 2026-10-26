const std = @import("std");
const Io = std.Io;
const rtsp = @import("rtsp/rtsp.zig");
const Parser = @import("rtsp/parser.zig").Parser;
const Response = @import("rtsp/response.zig").Response;

const SERVER = "10.10.10.238";
const PORT = 554;
const PATH = "/Streaming/Channels/101";
const USER = "admin";
const PASS = "pass";

pub fn main(init: std.process.Init) !void {
    const gpa = init.gpa;
    const io = init.io;

    var rtsp_client = try rtsp.RtspClient.init(gpa, io, .{
        .host = SERVER,
        .port = PORT,
        .path = PATH,
        .user = USER,
        .pass = PASS,
    });
    defer rtsp_client.deinit(gpa, io);

    rtsp_client.setDebug(true);

    var cesq = try rtsp_client.requestOptions();
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

    // Describe
    cesq = try rtsp_client.requestDescribe();
    if (try rtsp_client.readPacket()) |packet_response| {
        switch (packet_response) {
            .response => |response| Next: {
                if (response.cseq != cesq) {
                    return error.UnexpectedPacketCseq;
                }
                if (response.isSuccess()) {
                    break :Next;
                }
                if (response.isUnauthorized()) {
                    cesq = try rtsp_client.requestDescribe();
                    if (try rtsp_client.readPacket()) |retry_pkt| {
                        switch (retry_pkt) {
                            .response => |retry_resp| {
                                if (retry_resp.cseq != cesq) {
                                    return error.UnexpectedPacketCseq;
                                }
                                if (retry_resp.isSuccess()) {
                                    break :Next;
                                }
                                if (retry_resp.isUnauthorized()) {
                                    std.debug.print("--> Xác thực thất bại! Sai tài khoản hoặc mật khẩu ({s}:{s}).\n", .{ USER, PASS });
                                    return error.AuthenticationFailed;
                                } else {
                                    return error.UnexpectedPacket;
                                }
                            },
                            else => return error.UnexpectedPacket,
                        }
                    } else {
                        return error.UnexpectedPacket;
                    }
                } else {
                    return error.UnexpectedPacket;
                }
            },
            else => return error.UnexpectedPacket,
        }
    } else {
        std.debug.print("Request cesq {d} failed\n", .{cesq});
        return error.UnexpectedPacket;
    }

    var ping_count: usize = 0;
    while (ping_count < 10) : (ping_count += 1) {
        _ = try rtsp_client.ping();
        _ = try rtsp_client.readPacket();
        try io.sleep(std.Io.Duration.fromSeconds(5), .real);
        std.debug.print("Ping {d}\n", .{ping_count});
    }

    cesq = try rtsp_client.requestSetupTcp("trackID=1", 0, 1);
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
    while (true) {
        if (try rtsp_client.readPacket()) |packet_response| {
            switch (packet_response) {
                .response => |response| {
                    std.debug.print("Teardown response cesq {}\n", .{response.*.cseq});
                    break;
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
}
