const std = @import("std");
const c = @cImport(@cInclude("ini.h"));

const Configuration = struct { version: isize, name: []const u8, email: []const u8 };

fn handler(user: ?*c_void, section: [*c]const u8, name: [*c]const u8, value: [*c]const u8) callconv(.C) c_int {
    std.log.debug("{s}.{s} = {s}", .{ section, name, value });
    return 1;
}

pub fn main() anyerror!void {
    if (c.ini_parse("examples/test.ini", handler, null) < 0) {}
}
