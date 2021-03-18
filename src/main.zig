const std = @import("std");
const c = @cImport(@cInclude("ini.h"));

const Configuration = struct {
    version: isize,
    name: ?[]const u8,
    email: ?[]const u8,
};

fn strdup(s: []const u8) []const u8 {
    const new = std.heap.c_allocator.alloc(u8, s.len) catch unreachable;
    std.mem.copy(u8, new, s);
    return new;
}

fn handler(user: ?*c_void, section: [*c]const u8, name: [*c]const u8, value: [*c]const u8) callconv(.C) c_int {
    var conf = @ptrCast(*Configuration, @alignCast(@alignOf(*Configuration), user));
    var s = std.mem.span(section);
    var n = std.mem.span(name);
    var v = std.mem.span(value);
    if (std.mem.eql(u8, "protocol", s)) {
        conf.version = std.fmt.parseInt(isize, v, 10) catch unreachable;
    } else if (std.mem.eql(u8, "user", s)) {
        if (std.mem.eql(u8, "name", n)) {
            conf.name = strdup(v);
        } else if (std.mem.eql(u8, "email", n)) {
            conf.email = strdup(v);
        }
    }
    return 0;
}

pub fn main() anyerror!void {
    var buf: [1024]u8 = undefined;
    var allocator = std.heap.FixedBufferAllocator.init(&buf);
    var config: Configuration = undefined;
    _ = c.ini_parse("examples/test.ini", handler, &config);
    std.log.debug("ver={}, name={s}, email={s}", .{ config.version, config.name, config.email });
}
