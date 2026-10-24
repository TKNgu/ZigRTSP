const std = @import("std");

const State = enum {
    neurual_line,
    message_request_line,
    header_field,
    header_value,
    break_line,
};

pub fn Parser(comptime Callback: type) type {
    return struct {
        const Self = @This();

        callback: *Callback,
        state: State = .neurual_line,

        pub fn init(callback: *Callback) Self {
            return .{
                .callback = callback,
                .state = .neurual_line,
            };
        }

        pub fn parse(self: *Self, buffer: []u8) !void {
            var offset: usize = 0;
            while (offset < buffer.len) {
                switch (self.state) {
                    .neurual_line => {
                        const c = buffer[offset];
                        if (c == '$') {
                            return error.InvalidState;
                        } else if (c == 'r' or c == 'R') {
                            self.state = .message_request_line;
                            continue;
                        } else {
                            return error.InvalidNerualLine;
                        }
                    },
                    .message_request_line => {
                        const begin = offset;
                        while (offset < buffer.len and buffer[offset] != '\n') : (offset += 1) {}
                        try self.callback.requestLine(buffer[begin..offset]);
                        if (offset == buffer.len) {
                            return;
                        }
                        offset += 1;
                        try self.callback.endRequestLine();
                        self.state = .header_field;
                    },
                    .header_field => {
                        const begin = offset;
                        while (offset < buffer.len and buffer[offset] != ':') : (offset += 1) {}
                        try self.callback.headerField(buffer[begin..offset]);
                        if (offset == buffer.len) {
                            return;
                        }
                        offset += 1;
                        try self.callback.endHeaderField();
                        self.state = .header_value;
                    },
                    .header_value => {
                        const begin = offset;
                        while (offset < buffer.len and buffer[offset] != '\n') : (offset += 1) {}
                        try self.callback.headerValue(buffer[begin..offset]);
                        if (offset == buffer.len) {
                            return;
                        }
                        offset += 1;
                        try self.callback.endHeaderValue();
                        self.state = .break_line;
                    },
                    .break_line => {
                        if (buffer[offset] == '\r') {
                            if (offset == buffer.len) {
                                return;
                            }
                            offset += 1;
                            if (buffer[offset] == '\n') {
                                if (offset == buffer.len) {
                                    return;
                                }
                                offset += 1;
                                self.state = .neurual_line;
                                try self.callback.messageBegin(offset);
                                return;
                            }
                        } else {
                            self.state = .header_field;
                        }
                    },
                }
            }
        }
    };
}
