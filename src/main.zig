const std = @import("std");
const x = @import("x11.zig");

pub fn main() !void {
    const target = try x.Target.init();
    defer target.deinit();

    const win = try target.createWindow();
    defer win.deinit();

    std.time.sleep(3 * 1000 * 1000 * 1000);
}
