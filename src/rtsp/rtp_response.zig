const std = @import("std");

/// Tiêu đề khung đóng gói nhị phân xen kẽ RTSP Interleaved (RFC 2326 Mục 10.12).
/// Cấu trúc:
///   1 byte: Ký tự '$' (0x24)
///   1 byte: Số thứ tự kênh (Channel identifier)
///   2 bytes: Kích thước dữ liệu nhị phân (Big-endian, Network Byte Order)
pub const IntlHeader = struct {
    sign: u8 = '$',
    channel: u8 = 0,
    payload_size: u16 = 0,

    pub const SIZE: usize = 4;

    /// Phân tích tiêu đề 4 byte xen kẽ từ slice dữ liệu
    pub fn unpack(data: []const u8) !IntlHeader {
        if (data.len < SIZE) return error.IncompleteInterleavedHeader;
        if (data[0] != '$') return error.InvalidInterleavedSign;

        return .{
            .sign = data[0],
            .channel = data[1],
            .payload_size = std.mem.readInt(u16, data[2..4][0..2], .big),
        };
    }

    /// Ghi tiêu đề xen kẽ 4 bytes vào writer
    pub fn pack(self: *const IntlHeader, writer: *std.Io.Writer) !void {
        try writer.writeByte(self.sign);
        try writer.writeByte(self.channel);
        try writer.writeInt(u16, self.payload_size, .big);
    }

    pub inline fn size() usize {
        return SIZE;
    }
};

/// Tiêu đề cố định của gói tin RTP (RFC 3550 Mục 5.1 RTP Fixed Header Fields).
/// Cấu trúc chuẩn 12 bytes:
///  0                   1                   2                   3
///  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
/// +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
/// |V=2|P|X|  CC   |M|     PT      |       sequence number         |
/// +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
/// |                           timestamp                           |
/// +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
/// |           synchronization source (SSRC) identifier            |
/// +=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
pub const RtpHeader = struct {
    /// Phiên bản giao thức RTP (luôn là 2 theo RFC 3550)
    version: u2 = 2,
    /// Cờ đệm (Padding): gói tin có các byte đệm ở cuối payload
    padding: bool = false,
    /// Cờ mở rộng (Extension): có tiêu đề mở rộng sau fixed header
    extension: bool = false,
    /// Số lượng nguồn đóng góp CSRC (CSRC Count: 0 đến 15)
    csrc_count: u4 = 0,
    /// Cờ đánh dấu (Marker bit): ví dụ ranh giới frame video
    marker: bool = false,
    /// Loại dữ liệu payload (Payload Type: RFC 3551, ví dụ 96 = H.264, 97 = AAC)
    payload_type: u7 = 0,
    /// Số thứ tự tuần tự của gói RTP (Sequence Number)
    sequence_number: u16 = 0,
    /// Dấu thời gian lấy mẫu của media (Timestamp)
    timestamp: u32 = 0,
    /// Định danh nguồn đồng bộ (SSRC Identifier)
    ssrc: u32 = 0,

    pub const MIN_SIZE: usize = 12;

    /// Phân tích tiêu đề RTP và tính toán độ dài header tổng thể (gồm cả CSRC và Extension)
    pub fn unpack(data: []const u8) !struct { header: RtpHeader, header_len: usize, padding_len: u8 } {
        if (data.len < MIN_SIZE) return error.IncompleteRtpHeader;

        const b0 = data[0];
        const b1 = data[1];

        const version: u2 = @intCast((b0 >> 6) & 0x03);
        const padding = ((b0 >> 5) & 0x01) == 1;
        const extension = ((b0 >> 4) & 0x01) == 1;
        const csrc_count: u4 = @intCast(b0 & 0x0F);

        const marker = ((b1 >> 7) & 0x01) == 1;
        const payload_type: u7 = @intCast(b1 & 0x7F);

        const sequence_number = std.mem.readInt(u16, data[2..4][0..2], .big);
        const timestamp = std.mem.readInt(u32, data[4..8][0..4], .big);
        const ssrc = std.mem.readInt(u32, data[8..12][0..4], .big);

        var offset: usize = 12;

        // Bỏ qua danh sách CSRC identifiers (RFC 3550 Mục 5.1)
        const csrc_bytes = @as(usize, csrc_count) * 4;
        if (data.len < offset + csrc_bytes) return error.IncompleteRtpHeader;
        offset += csrc_bytes;

        // Bỏ qua phần tiêu đề mở rộng Header Extension (RFC 3550 Mục 5.3.1)
        if (extension) {
            if (data.len < offset + 4) return error.IncompleteRtpHeader;
            const ext_len_words = std.mem.readInt(u16, data[offset + 2 .. offset + 4][0..2], .big);
            const ext_bytes = @as(usize, ext_len_words) * 4;
            offset += 4;
            if (data.len < offset + ext_bytes) return error.IncompleteRtpHeader;
            offset += ext_bytes;
        }

        var padding_len: u8 = 0;
        if (padding) {
            if (data.len <= offset) return error.InvalidPadding;
            padding_len = data[data.len - 1];
            if (padding_len == 0 or offset + padding_len > data.len) return error.InvalidPadding;
        }

        return .{
            .header = .{
                .version = version,
                .padding = padding,
                .extension = extension,
                .csrc_count = csrc_count,
                .marker = marker,
                .payload_type = payload_type,
                .sequence_number = sequence_number,
                .timestamp = timestamp,
                .ssrc = ssrc,
            },
            .header_len = offset,
            .padding_len = padding_len,
        };
    }

    /// Đóng gói Fixed Header vào writer
    pub fn pack(self: *const RtpHeader, writer: *std.Io.Writer) !void {
        var b0: u8 = @as(u8, self.version) << 6;
        if (self.padding) b0 |= 0x20;
        if (self.extension) b0 |= 0x10;
        b0 |= @as(u8, self.csrc_count) & 0x0F;

        var b1: u8 = @as(u8, self.payload_type) & 0x7F;
        if (self.marker) b1 |= 0x80;

        try writer.writeByte(b0);
        try writer.writeByte(b1);
        try writer.writeInt(u16, self.sequence_number, .big);
        try writer.writeInt(u32, self.timestamp, .big);
        try writer.writeInt(u32, self.ssrc, .big);
    }
};

/// Tập hợp các cờ trạng thái biểu diễn tiến trình phân tích gói tin RTP
pub const Flags = struct {
    /// Đã phân tích thành công tiêu đề RTP
    header_complete: bool = false,
    /// Đã nhận và phân tích hoàn tất toàn bộ gói dữ liệu RTP
    packet_complete: bool = false,
    /// Gói tin là RTP (true) hoặc RTCP (false)
    is_rtcp: bool = false,

    pub fn reset(self: *Flags) void {
        self.* = .{};
    }
};

/// Lớp đối tượng biểu diễn gói phản hồi / dữ liệu RTP nhận được từ luồng RTSP (RFC 3550 & RFC 2326 Mục 10.12).
/// Thiết kế theo mô hình tối ưu:
/// 1. Tái sử dụng vùng nhớ ArenaAllocator (`retain_capacity`) để xử lý hàng ngàn gói/giây không phân mảnh bộ nhớ.
/// 2. Bóc tách tiêu đề RTP, danh sách CSRC, Extension và tự động loại bỏ Padding.
/// 3. Lấy trực tiếp lát cắt `payload` chứa dữ liệu video (H.264/H.265) hoặc audio (AAC/PCMA/PCMU).
/// 4. Đóng vai trò là Callback trực tiếp cho `Parser` khi stream Interleaved binary qua TCP.
pub const RTPResponser = struct {
    /// Bộ cấp phát gốc (GPA)
    allocator: std.mem.Allocator,
    /// Bộ cấp phát Arena gom bộ nhớ cho mỗi phiên đọc gói RTP
    arena_allocator: std.heap.ArenaAllocator,

    /// Kênh truyền tải xen kẽ (Channel ID: thường kênh chẵn 0, 2 là RTP; kênh lẻ 1, 3 là RTCP)
    channel: u8 = 0,
    /// Độ dài dữ liệu khai báo trong tiêu đề xen kẽ ($)
    interleaved_length: u16 = 0,

    /// Tiêu đề gói tin RTP
    header: RtpHeader = .{},
    /// Danh sách CSRC (nếu `csrc_count > 0`)
    csrc_list: []const u32 = &.{},
    /// Profile của Extension (nếu `extension == true`)
    extension_profile: u16 = 0,
    /// Dữ liệu mở rộng Extension
    extension_data: []const u8 = &.{},

    /// Bộ đệm lưu trữ dữ liệu gói thô nhận được từ kênh TCP
    raw_data: std.ArrayListUnmanaged(u8) = .empty,
    /// Lát cắt chứa nội dung media payload thực tế (sau khi đã trừ header và padding)
    payload: []const u8 = &.{},
    /// Kích thước phần đệm padding (nếu có)
    padding_size: u8 = 0,

    /// Các cờ trạng thái phân tích
    flags: Flags = .{},

    /// Khởi tạo một đối tượng đọc phản hồi RTP
    pub fn init(allocator: std.mem.Allocator) RTPResponser {
        return .{
            .allocator = allocator,
            .arena_allocator = std.heap.ArenaAllocator.init(allocator),
        };
    }

    /// Giải phóng toàn bộ bộ nhớ
    pub fn deinit(self: *RTPResponser) void {
        const arena = self.arena_allocator.allocator();
        self.raw_data.deinit(arena);
        self.arena_allocator.deinit();
    }

    /// Làm mới để chuẩn bị đọc gói tin RTP kế tiếp (tái sử dụng capacity đã cấp phát)
    pub fn reset(self: *RTPResponser) void {
        self.channel = 0;
        self.interleaved_length = 0;
        self.header = .{};
        self.csrc_list = &.{};
        self.extension_profile = 0;
        self.extension_data = &.{};
        self.raw_data = .empty;
        self.payload = &.{};
        self.padding_size = 0;
        self.flags.reset();
        _ = self.arena_allocator.reset(.retain_capacity);
    }

    /// Kiểm tra gói tin RTP đã được nhận và phân tích hoàn tất hay chưa
    pub fn isComplete(self: *const RTPResponser) bool {
        return self.flags.packet_complete;
    }

    /// Kiểm tra xem gói tin có phải là RTCP (dựa trên channel lẻ hoặc payload type 200..204)
    pub fn isRtcp(self: *const RTPResponser) bool {
        if ((self.channel % 2) == 1) return true;
        const pt = self.header.payload_type;
        return pt >= 200 and pt <= 204;
    }

    /// Lấy lát cắt phần thân dữ liệu media (H.264 NALU, AAC frame...)
    pub fn getPayload(self: *const RTPResponser) []const u8 {
        return self.payload;
    }

    /// Lấy toàn bộ mảng byte thô của gói RTP
    pub fn getRawData(self: *const RTPResponser) []const u8 {
        return self.raw_data.items;
    }

    /// Lấy số thứ tự kênh xen kẽ (Channel ID)
    pub fn getChannel(self: *const RTPResponser) u8 {
        return self.channel;
    }

    /// Lấy tiêu đề RTP
    pub fn getHeader(self: *const RTPResponser) RtpHeader {
        return self.header;
    }

    /// Lấy số thứ tự gói RTP (Sequence Number)
    pub fn getSequenceNumber(self: *const RTPResponser) u16 {
        return self.header.sequence_number;
    }

    /// Lấy dấu thời gian media (Timestamp)
    pub fn getTimestamp(self: *const RTPResponser) u32 {
        return self.header.timestamp;
    }

    /// Lấy loại Payload Type (ví dụ 96 = video, 97 = audio)
    pub fn getPayloadType(self: *const RTPResponser) u7 {
        return self.header.payload_type;
    }

    /// Lấy cờ Marker (true biểu thị kết thúc một frame video)
    pub fn isMarker(self: *const RTPResponser) bool {
        return self.header.marker;
    }

    /// Lấy SSRC nguồn đồng bộ
    pub fn getSsrc(self: *const RTPResponser) u32 {
        return self.header.ssrc;
    }

    /// Lấy danh sách CSRC IDs (nếu có)
    pub fn getCsrcList(self: *const RTPResponser) []const u32 {
        return self.csrc_list;
    }

    /// Lấy dữ liệu Header Extension (nếu có)
    pub fn getExtensionData(self: *const RTPResponser) []const u8 {
        return self.extension_data;
    }

    /// In chi tiết gói tin RTP/RTCP ra console phục vụ debug
    pub fn dump(self: *const RTPResponser) void {
        if (self.isRtcp()) {
            std.debug.print("---------- [RTCP PACKET] -----------\n", .{});
            std.debug.print("Channel: {d} | Raw Length: {d} bytes\n", .{
                self.channel,
                self.raw_data.items.len,
            });
            std.debug.print("-------------------------------------\n", .{});
            return;
        }

        std.debug.print("----------- [RTP PACKET] ------------\n", .{});
        std.debug.print("Channel: {d} | Seq: {d} | Timestamp: {d} | PT: {d} | Marker: {}\n", .{
            self.channel,
            self.header.sequence_number,
            self.header.timestamp,
            self.header.payload_type,
            self.header.marker,
        });
        std.debug.print("SSRC: 0x{X:0>8} | CSRC count: {d} | Extension: {} | Padding: {d}\n", .{
            self.header.ssrc,
            self.header.csrc_count,
            self.header.extension,
            self.padding_size,
        });
        std.debug.print("Payload size: {d} bytes\n", .{self.payload.len});

        // In 16 byte đầu của payload dạng hex preview nếu có
        if (self.payload.len > 0) {
            std.debug.print("Payload preview (hex): ", .{});
            const preview_len = @min(self.payload.len, 16);
            for (self.payload[0..preview_len]) |byte| {
                std.debug.print("{X:0>2} ", .{byte});
            }
            if (self.payload.len > 16) {
                std.debug.print("...", .{});
            }
            std.debug.print("\n", .{});
        }
        std.debug.print("-------------------------------------\n", .{});
    }

    // =========================================================================
    // Các phương thức phân tích cú pháp (Parsing Methods)
    // =========================================================================

    /// Phân tích dữ liệu gói RTP trực tiếp từ bộ đệm (áp dụng cho cả UDP hoặc TCP)
    pub fn parse(self: *RTPResponser, channel: u8, data: []const u8) !void {
        self.reset();
        self.channel = channel;
        self.interleaved_length = @intCast(data.len);
        try self.raw_data.appendSlice(self.arena_allocator.allocator(), data);
        try self.unpackRtp();
        self.flags.packet_complete = true;
    }

    /// Phân tích khung xen kẽ hoàn chỉnh có chứa 4 byte IntlHeader ($ + channel + len + rtp_data)
    pub fn parseInterleaved(self: *RTPResponser, frame: []const u8) !void {
        const intl = try IntlHeader.unpack(frame);
        if (frame.len < IntlHeader.SIZE + intl.payload_size) {
            return error.IncompleteInterleavedData;
        }
        const data = frame[IntlHeader.SIZE .. IntlHeader.SIZE + intl.payload_size];
        try self.parse(intl.channel, data);
    }

    /// Bóc tách các thành phần tiêu đề RTP và gán lát cắt payload
    fn unpackRtp(self: *RTPResponser) !void {
        const data = self.raw_data.items;
        const res = try RtpHeader.unpack(data);
        self.header = res.header;
        self.flags.header_complete = true;

        if (self.isRtcp()) {
            self.flags.is_rtcp = true;
        }

        const arena = self.arena_allocator.allocator();

        // Bóc tách danh sách CSRC
        if (self.header.csrc_count > 0) {
            const csrcs = try arena.alloc(u32, self.header.csrc_count);
            for (0..self.header.csrc_count) |i| {
                const start = 12 + i * 4;
                csrcs[i] = std.mem.readInt(u32, data[start .. start + 4][0..4], .big);
            }
            self.csrc_list = csrcs;
        }

        // Bóc tách phần Extension
        if (self.header.extension) {
            const ext_start = 12 + @as(usize, self.header.csrc_count) * 4;
            self.extension_profile = std.mem.readInt(u16, data[ext_start .. ext_start + 2][0..2], .big);
            const ext_len_words = std.mem.readInt(u16, data[ext_start + 2 .. ext_start + 4][0..2], .big);
            const ext_bytes = @as(usize, ext_len_words) * 4;
            self.extension_data = data[ext_start + 4 .. ext_start + 4 + ext_bytes];
        }

        // Bóc tách Payload và loại trừ Padding
        self.padding_size = res.padding_len;
        const end_offset = data.len - res.padding_len;
        if (end_offset >= res.header_len) {
            self.payload = data[res.header_len..end_offset];
        } else {
            return error.InvalidRtpPayload;
        }
    }

    // =========================================================================
    // Callbacks tích hợp trực tiếp với Parser (llhttp-style streaming)
    // =========================================================================

    pub fn onInterleavedBegin(self: *RTPResponser, channel: u8, length: u16) !void {
        self.reset();
        self.channel = channel;
        self.interleaved_length = length;
    }

    pub fn onInterleavedData(self: *RTPResponser, channel: u8, chunk: []const u8) !void {
        _ = channel;
        try self.raw_data.appendSlice(self.arena_allocator.allocator(), chunk);
    }

    pub fn onInterleavedComplete(self: *RTPResponser, channel: u8) !void {
        self.channel = channel;
        try self.unpackRtp();
        self.flags.packet_complete = true;
    }

    // Callbacks legacy
    pub fn onInterleaved(self: *RTPResponser, channel: u8, chunk: []const u8) !void {
        try self.onInterleavedData(channel, chunk);
    }

    // =========================================================================
    // Xuất dữ liệu / Serialization
    // =========================================================================

    /// Ghi toàn bộ gói RTP dưới dạng Interleaved binary frame ($ + channel + len + rtp) ra writer
    pub fn writeInterleaved(self: *const RTPResponser, writer: *std.Io.Writer) !void {
        const intl = IntlHeader{
            .sign = '$',
            .channel = self.channel,
            .payload_size = @intCast(self.raw_data.items.len),
        };
        try intl.pack(writer);
        try writer.writeAll(self.raw_data.items);
    }

    /// Ghi gói RTP thô (header + payload) ra writer
    pub fn writeRtp(self: *const RTPResponser, writer: *std.Io.Writer) !void {
        try writer.writeAll(self.raw_data.items);
    }
};

/// Bí danh ngắn gọn tương thích
pub const RtpResponse = RTPResponser;
pub const RtpResponser = RTPResponser;
pub const RtpPacket = RTPResponser;

// =============================================================================
// Unit Tests cho RTPResponser & RtpHeader
// =============================================================================

test "RtpHeader basic unpack and getters" {
    const testing = std.testing;

    // V=2, P=0, X=0, CC=0, M=1, PT=96 (0x60), Seq=1001 (0x03E9), TS=123456 (0x0001E240), SSRC=0x11223344
    const rtp_raw = [_]u8{
        0x80, 0xE0, 0x03, 0xE9,
        0x00, 0x01, 0xE2, 0x40,
        0x11, 0x22, 0x33, 0x44,
        0xAA, 0xBB, 0xCC, 0xDD, // 4 bytes payload
    };

    var rtp = RTPResponser.init(testing.allocator);
    defer rtp.deinit();

    try rtp.parse(0, &rtp_raw);

    try testing.expect(rtp.isComplete());
    try testing.expectEqual(@as(u8, 0), rtp.getChannel());
    try testing.expectEqual(@as(u2, 2), rtp.header.version);
    try testing.expectEqual(false, rtp.header.padding);
    try testing.expectEqual(false, rtp.header.extension);
    try testing.expectEqual(@as(u4, 0), rtp.header.csrc_count);
    try testing.expectEqual(true, rtp.isMarker());
    try testing.expectEqual(@as(u7, 96), rtp.getPayloadType());
    try testing.expectEqual(@as(u16, 1001), rtp.getSequenceNumber());
    try testing.expectEqual(@as(u32, 123456), rtp.getTimestamp());
    try testing.expectEqual(@as(u32, 0x11223344), rtp.getSsrc());

    // Payload verification
    try testing.expectEqual(@as(usize, 4), rtp.getPayload().len);
    try testing.expectEqualStrings(&[_]u8{ 0xAA, 0xBB, 0xCC, 0xDD }, rtp.getPayload());
}

test "RTPResponser with CSRC list" {
    const testing = std.testing;

    // V=2, P=0, X=0, CC=2 (0x82), M=0, PT=97, Seq=50, TS=90000, SSRC=0x10203040
    // CSRC 1: 0x01020304
    // CSRC 2: 0x05060708
    // Payload: "HELLO_AUDIO"
    const rtp_raw = [_]u8{
        0x82, 0x61, 0x00, 0x32,
        0x00, 0x01, 0x5F, 0x90,
        0x10, 0x20, 0x30, 0x40,
        0x01, 0x02, 0x03, 0x04, // CSRC 1
        0x05, 0x06, 0x07, 0x08, // CSRC 2
        'H',  'E',  'L',  'L',
        'O',  '_',  'A',  'U',
        'D',  'I',  'O',
    };

    var rtp = RTPResponser.init(testing.allocator);
    defer rtp.deinit();

    try rtp.parse(2, &rtp_raw);

    try testing.expect(rtp.isComplete());
    try testing.expectEqual(@as(u8, 2), rtp.getChannel());
    try testing.expectEqual(@as(u4, 2), rtp.header.csrc_count);
    try testing.expectEqual(@as(usize, 2), rtp.getCsrcList().len);
    try testing.expectEqual(@as(u32, 0x01020304), rtp.getCsrcList()[0]);
    try testing.expectEqual(@as(u32, 0x05060708), rtp.getCsrcList()[1]);
    try testing.expectEqualStrings("HELLO_AUDIO", rtp.getPayload());
}

test "RTPResponser with Extension header" {
    const testing = std.testing;

    // V=2, P=0, X=1, CC=0 (0x90), M=0, PT=96, Seq=10, TS=1000, SSRC=0x99999999
    // Extension: Profile 0xBEDE (1-byte header RFC 5285), Length = 1 word (4 bytes)
    // Ext data: 0x11, 0x22, 0x33, 0x44
    // Payload: "VIDEO_NALU"
    const rtp_raw = [_]u8{
        0x90, 0x60, 0x00, 0x0A,
        0x00, 0x00, 0x03, 0xE8,
        0x99, 0x99, 0x99, 0x99,
        0xBE, 0xDE, 0x00, 0x01, // Profile=0xBEDE, Len=1 (4 bytes)
        0x11, 0x22, 0x33, 0x44, // Ext data
        'V',  'I',  'D',  'E',
        'O',  '_',  'N',  'A',
        'L',  'U',
    };

    var rtp = RTPResponser.init(testing.allocator);
    defer rtp.deinit();

    try rtp.parse(0, &rtp_raw);

    try testing.expect(rtp.isComplete());
    try testing.expectEqual(true, rtp.header.extension);
    try testing.expectEqual(@as(u16, 0xBEDE), rtp.extension_profile);
    try testing.expectEqual(@as(usize, 4), rtp.getExtensionData().len);
    try testing.expectEqualStrings(&[_]u8{ 0x11, 0x22, 0x33, 0x44 }, rtp.getExtensionData());
    try testing.expectEqualStrings("VIDEO_NALU", rtp.getPayload());
}

test "RTPResponser with Padding" {
    const testing = std.testing;

    // V=2, P=1, X=0, CC=0 (0xA0), M=0, PT=96, Seq=1, TS=100, SSRC=0x11111111
    // Payload: 4 bytes (0x01, 0x02, 0x03, 0x04)
    // Padding: 4 bytes (0x00, 0x00, 0x00, 0x04) -> last byte = 4
    const rtp_raw = [_]u8{
        0xA0, 0x60, 0x00, 0x01,
        0x00, 0x00, 0x00, 0x64,
        0x11, 0x11, 0x11, 0x11,
        0x01, 0x02, 0x03, 0x04, // payload
        0x00, 0x00, 0x00, 0x04, // 4 bytes padding (last byte is padding count)
    };

    var rtp = RTPResponser.init(testing.allocator);
    defer rtp.deinit();

    try rtp.parse(0, &rtp_raw);

    try testing.expect(rtp.isComplete());
    try testing.expectEqual(true, rtp.header.padding);
    try testing.expectEqual(@as(u8, 4), rtp.padding_size);
    try testing.expectEqual(@as(usize, 4), rtp.getPayload().len);
    try testing.expectEqualStrings(&[_]u8{ 0x01, 0x02, 0x03, 0x04 }, rtp.getPayload());
}

test "RTPResponser parseInterleaved" {
    const testing = std.testing;

    // Interleaved frame: '$' + channel 1 + len 16 + RTP packet (12 bytes header + 4 bytes payload)
    const frame = [_]u8{
        '$',  0x01, 0x00, 0x10,
        0x80, 0xC8, 0x00, 0x01, // PT=200 (RTCP SR)
        0x00, 0x00, 0x00, 0x01,
        0x12, 0x34, 0x56, 0x78,
        0xDE, 0xAD, 0xBE, 0xEF,
    };

    var rtp = RTPResponser.init(testing.allocator);
    defer rtp.deinit();

    try rtp.parseInterleaved(&frame);

    try testing.expect(rtp.isComplete());
    try testing.expectEqual(@as(u8, 1), rtp.getChannel());
    try testing.expect(rtp.isRtcp());
    try testing.expectEqualStrings(&[_]u8{ 0xDE, 0xAD, 0xBE, 0xEF }, rtp.getPayload());
}

test "RTPResponser arena reuse retain_capacity across multiple packets" {
    const testing = std.testing;

    var rtp = RTPResponser.init(testing.allocator);
    defer rtp.deinit();

    const p1 = [_]u8{
        0x80, 0x60, 0x00, 0x01,
        0x00, 0x00, 0x00, 0x64,
        0x11, 0x11, 0x11, 0x11,
        'P',  'A',  'C',  'K',  'E', 'T', '1',
    };

    const p2 = [_]u8{
        0x80, 0x60, 0x00, 0x02,
        0x00, 0x00, 0x00, 0xC8,
        0x11, 0x11, 0x11, 0x11,
        'P',  'A',  'C',  'K',  'E', 'T', '2', '_', 'L', 'O', 'N', 'G', 'E', 'R',
    };

    try rtp.parse(0, &p1);
    try testing.expectEqual(@as(u16, 1), rtp.getSequenceNumber());
    try testing.expectEqualStrings("PACKET1", rtp.getPayload());

    // Reset and parse packet 2
    rtp.reset();
    try rtp.parse(0, &p2);
    try testing.expectEqual(@as(u16, 2), rtp.getSequenceNumber());
    try testing.expectEqualStrings("PACKET2_LONGER", rtp.getPayload());
}

test "RTPResponser streaming via Parser with 1-byte TCP chunks" {
    const testing = std.testing;
    const Parser = @import("parser.zig").Parser;

    var rtp = RTPResponser.init(testing.allocator);
    defer rtp.deinit();

    // Stream an interleaved frame: '$' + channel 0 + length 16 + RTP packet (12 bytes header + 4 bytes payload)
    const frame = [_]u8{
        '$',  0x00, 0x00, 0x10, // Interleaved header: channel 0, len 16
        0x80, 0x60, 0x00, 0x05, // V=2, M=0, PT=96, Seq=5
        0x00, 0x00, 0x03, 0xE8, // TS=1000
        0x12, 0x34, 0x56, 0x78, // SSRC=0x12345678
        0xAA, 0xBB, 0xCC, 0xDD, // Payload (4 bytes)
    };

    var parser = Parser(RTPResponser).init(&rtp);

    // Truyền từng byte một để kiểm tra tính chịu phân mảnh tuyệt đối của parser
    for (frame) |b| {
        const slice = [_]u8{b};
        try parser.parse(&slice);
    }

    try testing.expect(rtp.isComplete());
    try testing.expectEqual(@as(u8, 0), rtp.getChannel());
    try testing.expectEqual(@as(u16, 5), rtp.getSequenceNumber());
    try testing.expectEqual(@as(u32, 1000), rtp.getTimestamp());
    try testing.expectEqual(@as(u7, 96), rtp.getPayloadType());
    try testing.expectEqual(@as(u32, 0x12345678), rtp.getSsrc());
    try testing.expectEqual(@as(usize, 4), rtp.getPayload().len);
    try testing.expectEqualStrings(&[_]u8{ 0xAA, 0xBB, 0xCC, 0xDD }, rtp.getPayload());
}
