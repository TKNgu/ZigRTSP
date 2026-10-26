const std = @import("std");

/// Kiểu xác thực được máy chủ RTSP yêu cầu trong header WWW-Authenticate (RFC 2326 Mục 12.44)
pub const AuthType = enum {
    basic,
    digest,

    pub fn asString(self: AuthType) []const u8 {
        return switch (self) {
            .basic => "Basic",
            .digest => "Digest",
        };
    }
};

/// Cặp thông tin tài khoản người dùng
pub const Credentials = struct {
    username: []const u8,
    password: []const u8,
};

/// Cấu trúc lưu trữ thông tin thách thức xác thực (Authentication Challenge) từ WWW-Authenticate
pub const AuthChallenge = struct {
    /// Kiểu xác thực: Basic hoặc Digest
    auth_type: AuthType,
    /// Vùng xác thực do máy chủ chỉ định (ví dụ: "IP Camera" hoặc "LIVE555 Streaming Media")
    realm: []const u8,
    /// Chuỗi ngẫu nhiên do máy chủ tạo ra (chỉ dùng cho Digest)
    nonce: ?[]const u8 = null,
    /// Quality of Protection: "auth" hoặc "auth-int" (chỉ dùng cho Digest)
    qop: ?[]const u8 = null,
    /// Dữ liệu opaque mà máy chủ gửi và client phải gửi lại nguyên vẹn (chỉ dùng cho Digest)
    @"opaque": ?[]const u8 = null,
    /// Thuật toán băm: "MD5" hoặc "SHA-256" (mặc định MD5 nếu null)
    algorithm: ?[]const u8 = null,
    /// Cờ báo hiệu nonce đã cũ và cần tạo lại phiên xác thực mới
    stale: bool = false,

    /// Phân tích giá trị của trường tiêu đề "WWW-Authenticate"
    /// Hỗ trợ cả Basic và Digest:
    /// - Basic realm="IP Camera"
    /// - Digest realm="IP Camera", nonce="4b3f8a9e", qop="auth"
    pub fn parse(header_value: []const u8) ?AuthChallenge {
        const trimmed = std.mem.trim(u8, header_value, " \t\r\n");
        if (trimmed.len == 0) return null;

        var auth_type: AuthType = undefined;
        var rest: []const u8 = undefined;

        if (startsWithIgnoreCase(trimmed, "Basic ")) {
            auth_type = .basic;
            rest = std.mem.trimStart(u8, trimmed[6..], " \t");
        } else if (startsWithIgnoreCase(trimmed, "Digest ")) {
            auth_type = .digest;
            rest = std.mem.trimStart(u8, trimmed[7..], " \t");
        } else {
            return null;
        }

        const realm = extractParam(rest, "realm") orelse "";
        const nonce = extractParam(rest, "nonce");
        const qop = extractParam(rest, "qop");
        const opaque_val = extractParam(rest, "opaque");
        const algorithm = extractParam(rest, "algorithm");
        const stale_val = extractParam(rest, "stale");

        const stale = if (stale_val) |s|
            std.ascii.eqlIgnoreCase(s, "true")
        else
            false;

        return .{
            .auth_type = auth_type,
            .realm = realm,
            .nonce = nonce,
            .qop = qop,
            .@"opaque" = opaque_val,
            .algorithm = algorithm,
            .stale = stale,
        };
    }

    /// Trích xuất giá trị tham số dạng key="value" hoặc key=value từ chuỗi tham số
    pub fn extractParam(params: []const u8, key: []const u8) ?[]const u8 {
        var idx: usize = 0;
        while (idx < params.len) {
            // Bỏ qua dấu phẩy và khoảng trắng phân cách
            while (idx < params.len and (params[idx] == ',' or params[idx] == ' ' or params[idx] == '\t')) : (idx += 1) {}
            if (idx >= params.len) break;

            const start_key = idx;
            while (idx < params.len and params[idx] != '=' and params[idx] != ' ' and params[idx] != ',') : (idx += 1) {}
            const current_key = params[start_key..idx];

            while (idx < params.len and params[idx] == ' ') : (idx += 1) {}
            if (idx < params.len and params[idx] == '=') {
                idx += 1;
                while (idx < params.len and params[idx] == ' ') : (idx += 1) {}

                var val: []const u8 = "";
                if (idx < params.len and params[idx] == '"') {
                    // Giá trị trong dấu ngoặc kép "..."
                    idx += 1;
                    const val_start = idx;
                    while (idx < params.len and params[idx] != '"') : (idx += 1) {}
                    val = params[val_start..idx];
                    if (idx < params.len and params[idx] == '"') idx += 1;
                } else {
                    // Giá trị không có ngoặc kép, kết thúc bằng dấu phẩy hoặc hết chuỗi
                    const val_start = idx;
                    while (idx < params.len and params[idx] != ',' and params[idx] != ' ' and params[idx] != '\t') : (idx += 1) {}
                    val = params[val_start..idx];
                }

                if (std.ascii.eqlIgnoreCase(current_key, key)) {
                    return val;
                }
            }
        }
        return null;
    }
};

/// Tham số tùy chọn để sinh chuỗi xác thực Digest (RFC 2617)
pub const DigestOptions = struct {
    username: []const u8,
    password: []const u8,
    realm: []const u8,
    nonce: []const u8,
    uri: []const u8,
    method: []const u8,
    qop: ?[]const u8 = null,
    nc: u32 = 1,
    cnonce: ?[]const u8 = null,
    @"opaque": ?[]const u8 = null,
    algorithm: ?[]const u8 = null,
};

/// Tính giá trị MD5 dạng chuỗi Hex thường (32 ký tự)
pub fn md5Hex(data: []const u8, out_hex: *[32]u8) void {
    var digest: [std.crypto.hash.Md5.digest_length]u8 = undefined;
    std.crypto.hash.Md5.hash(data, &digest, .{});
    out_hex.* = std.fmt.bytesToHex(digest, .lower);
}

/// Sinh chuỗi header Authorization theo chuẩn Basic (RFC 7617)
/// Định dạng: "Basic <base64(username:password)>"
pub fn generateBasicAuth(allocator: std.mem.Allocator, username: []const u8, password: []const u8) ![]u8 {
    const raw_len = username.len + 1 + password.len;
    const raw_buf = try allocator.alloc(u8, raw_len);
    defer allocator.free(raw_buf);

    _ = try std.fmt.bufPrint(raw_buf, "{s}:{s}", .{ username, password });

    const b64_len = std.base64.standard.Encoder.calcSize(raw_len);
    const b64_buf = try allocator.alloc(u8, b64_len);
    defer allocator.free(b64_buf);

    _ = std.base64.standard.Encoder.encode(b64_buf, raw_buf);

    return try std.fmt.allocPrint(allocator, "Basic {s}", .{b64_buf});
}

/// Sinh chuỗi header Authorization theo chuẩn Digest Access Authentication (RFC 2617)
/// Tính toán:
///   HA1 = MD5(username:realm:password)
///   HA2 = MD5(method:uri)
///   Nếu có qop:
///     Response = MD5(HA1:nonce:nc:cnonce:qop:HA2)
///   Nếu không có qop (RFC 2069 legacy):
///     Response = MD5(HA1:nonce:HA2)
pub fn generateDigestAuth(allocator: std.mem.Allocator, opts: DigestOptions) ![]u8 {
    // 1. Tính HA1 = MD5(username:realm:password)
    var ha1_hex: [32]u8 = undefined;
    {
        const ha1_raw = try std.fmt.allocPrint(allocator, "{s}:{s}:{s}", .{ opts.username, opts.realm, opts.password });
        defer allocator.free(ha1_raw);
        md5Hex(ha1_raw, &ha1_hex);
    }

    // 2. Tính HA2 = MD5(method:uri)
    var ha2_hex: [32]u8 = undefined;
    {
        const ha2_raw = try std.fmt.allocPrint(allocator, "{s}:{s}", .{ opts.method, opts.uri });
        defer allocator.free(ha2_raw);
        md5Hex(ha2_raw, &ha2_hex);
    }

    // 3. Tính Response
    var resp_hex: [32]u8 = undefined;
    var nc_buf: [8]u8 = undefined;
    _ = try std.fmt.bufPrint(&nc_buf, "{x:0>8}", .{opts.nc});

    const cnonce = opts.cnonce orelse "0a4f113b";

    // Kiểm tra xem qop có hỗ trợ "auth" không
    const use_qop_auth = if (opts.qop) |q|
        std.mem.indexOf(u8, q, "auth") != null
    else
        false;

    if (use_qop_auth) {
        // RFC 2617: MD5(HA1:nonce:nc:cnonce:qop:HA2)
        const resp_raw = try std.fmt.allocPrint(allocator, "{s}:{s}:{s}:{s}:auth:{s}", .{
            ha1_hex,
            opts.nonce,
            nc_buf,
            cnonce,
            ha2_hex,
        });
        defer allocator.free(resp_raw);
        md5Hex(resp_raw, &resp_hex);
    } else {
        // RFC 2069 legacy: MD5(HA1:nonce:HA2)
        const resp_raw = try std.fmt.allocPrint(allocator, "{s}:{s}:{s}", .{
            ha1_hex,
            opts.nonce,
            ha2_hex,
        });
        defer allocator.free(resp_raw);
        md5Hex(resp_raw, &resp_hex);
    }

    // 4. Xây dựng chuỗi Authorization header
    var list: std.ArrayListUnmanaged(u8) = .empty;
    defer list.deinit(allocator);

    try list.appendSlice(allocator, "Digest username=\"");
    try list.appendSlice(allocator, opts.username);
    try list.appendSlice(allocator, "\", realm=\"");
    try list.appendSlice(allocator, opts.realm);
    try list.appendSlice(allocator, "\", nonce=\"");
    try list.appendSlice(allocator, opts.nonce);
    try list.appendSlice(allocator, "\", uri=\"");
    try list.appendSlice(allocator, opts.uri);
    try list.appendSlice(allocator, "\", response=\"");
    try list.appendSlice(allocator, &resp_hex);
    try list.appendSlice(allocator, "\"");

    if (use_qop_auth) {
        try list.appendSlice(allocator, ", qop=auth, nc=");
        try list.appendSlice(allocator, &nc_buf);
        try list.appendSlice(allocator, ", cnonce=\"");
        try list.appendSlice(allocator, cnonce);
        try list.appendSlice(allocator, "\"");
    }

    if (opts.@"opaque") |op| {
        try list.appendSlice(allocator, ", opaque=\"");
        try list.appendSlice(allocator, op);
        try list.appendSlice(allocator, "\"");
    }

    if (opts.algorithm) |alg| {
        try list.appendSlice(allocator, ", algorithm=\"");
        try list.appendSlice(allocator, alg);
        try list.appendSlice(allocator, "\"");
    }

    return try list.toOwnedSlice(allocator);
}

/// Tự động sinh chuỗi Authorization thích hợp dựa trên thông tin thách thức AuthChallenge
pub fn generateAuthorization(
    allocator: std.mem.Allocator,
    challenge: AuthChallenge,
    username: []const u8,
    password: []const u8,
    method: []const u8,
    uri: []const u8,
    nc: u32,
) ![]u8 {
    return switch (challenge.auth_type) {
        .basic => try generateBasicAuth(allocator, username, password),
        .digest => try generateDigestAuth(allocator, .{
            .username = username,
            .password = password,
            .realm = challenge.realm,
            .nonce = challenge.nonce orelse "",
            .uri = uri,
            .method = method,
            .qop = challenge.qop,
            .nc = nc,
            .@"opaque" = challenge.@"opaque",
            .algorithm = challenge.algorithm,
        }),
    };
}

fn startsWithIgnoreCase(haystack: []const u8, needle: []const u8) bool {
    if (haystack.len < needle.len) return false;
    return std.ascii.eqlIgnoreCase(haystack[0..needle.len], needle);
}

// ==========================================
// Unit Tests cho Module Xác Thực Auth
// ==========================================

test "Parse Basic AuthChallenge" {
    const testing = std.testing;
    const header = "Basic realm=\"WallyWorld\"";
    const challenge = AuthChallenge.parse(header);

    try testing.expect(challenge != null);
    const ch = challenge.?;
    try testing.expectEqual(AuthType.basic, ch.auth_type);
    try testing.expectEqualStrings("WallyWorld", ch.realm);
    try testing.expect(ch.nonce == null);
}

test "Parse Digest AuthChallenge with qop and opaque" {
    const testing = std.testing;
    const header = "Digest realm=\"IP Camera\", nonce=\"dcd98b7102dd2f0e8b11d0f600bfb0c093\", qop=\"auth\", opaque=\"5ccc069c403ebaf9f0171e9517f40e41\"";
    const challenge = AuthChallenge.parse(header);

    try testing.expect(challenge != null);
    const ch = challenge.?;
    try testing.expectEqual(AuthType.digest, ch.auth_type);
    try testing.expectEqualStrings("IP Camera", ch.realm);
    try testing.expectEqualStrings("dcd98b7102dd2f0e8b11d0f600bfb0c093", ch.nonce.?);
    try testing.expectEqualStrings("auth", ch.qop.?);
    try testing.expectEqualStrings("5ccc069c403ebaf9f0171e9517f40e41", ch.@"opaque".?);
}

test "Generate Basic Auth header" {
    const testing = std.testing;
    const auth = try generateBasicAuth(testing.allocator, "admin", "12345");
    defer testing.allocator.free(auth);

    try testing.expectEqualStrings("Basic YWRtaW46MTIzNDU=", auth);
}

test "Generate Digest Auth header RFC 2617 compliance" {
    const testing = std.testing;
    const auth = try generateDigestAuth(testing.allocator, .{
        .username = "Mufasa",
        .password = "Circle Of Life",
        .realm = "testrealm@host.com",
        .nonce = "dcd98b7102dd2f0e8b11d0f600bfb0c093",
        .uri = "/dir/index.html",
        .method = "GET",
        .qop = "auth",
        .nc = 1,
        .cnonce = "0a4f113b",
        .@"opaque" = "5ccc069c403ebaf9f0171e9517f40e41",
    });
    defer testing.allocator.free(auth);

    // Kiểm tra chuỗi chứa đúng response hash chuẩn RFC 2617
    try testing.expect(std.mem.indexOf(u8, auth, "response=\"6629fae49393a05397450978507c4ef1\"") != null);
    try testing.expect(std.mem.indexOf(u8, auth, "nc=00000001") != null);
    try testing.expect(std.mem.indexOf(u8, auth, "cnonce=\"0a4f113b\"") != null);
    try testing.expect(std.mem.indexOf(u8, auth, "qop=auth") != null);
    try testing.expect(std.mem.indexOf(u8, auth, "opaque=\"5ccc069c403ebaf9f0171e9517f40e41\"") != null);
}

test "Generate Digest Auth header legacy RFC 2069 (no qop)" {
    const testing = std.testing;
    const auth = try generateDigestAuth(testing.allocator, .{
        .username = "Mufasa",
        .password = "Circle Of Life",
        .realm = "testrealm@host.com",
        .nonce = "dcd98b7102dd2f0e8b11d0f600bfb0c093",
        .uri = "/dir/index.html",
        .method = "GET",
        .qop = null,
    });
    defer testing.allocator.free(auth);

    try testing.expect(std.mem.indexOf(u8, auth, "response=\"670fd8c2df070c60b045671b8b24ff02\"") != null);
    try testing.expect(std.mem.indexOf(u8, auth, "qop") == null);
}
