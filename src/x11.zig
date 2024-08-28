const std = @import("std");
const c = @import("c.zig");

const XErr = error{
    // Target errors
    OpenDisplay,
    NoopCmd,
    Flush,

    // Window errors
    ClearWin,
    MapWin,
    UnmapWin,
    DestroyWin,
};

pub const Window = struct {
    target: Target,
    handle: c.Window,

    pub fn clear(self: Window) XErr!void {
        if (c.XClearWindow(self.target.display, self.handle) == 0) {
            return XErr.ClearWin;
        }
    }

    pub fn flush(self: Window) XErr!void {
        return self.target.flush();
    }

    pub fn deinit(self: Window) void {
        // ignore unmap errors for now
        if (c.XUnmapWindow(self.target.display, self.handle) == 0) {
            // TODO (soggy): consider accepting a log function for these
            std.log.warn("failed to unmap window", .{});
        }

        if (c.XDestroyWindow(self.target.display, self.handle) == 0) {
            std.log.warn("failed to destroy window", .{});
        }
    }
};

pub const Target = struct {
    display: ?*c.Display,
    screen: c_int,
    root_win: c.Window,

    pub fn init() XErr!Target {
        const display = try initDisplay();
        const screen = c.XDefaultScreen(display);

        return Target{
            .display = display,
            .screen = screen,
            .root_win = c.XRootWindow(display, screen),
        };
    }

    pub fn clearWindow(self: Target) XErr!void {
        if (self.window) |win| {
            if (c.XClearWindow(self.display, win) == 0) {
                return XErr.ClearWin;
            }
        }
    }

    pub fn createWindow(self: Target) XErr!Window {
        const white = c.XWhitePixel(self.display, self.screen);
        const black = c.XBlackPixel(self.display, self.screen);

        const handle = c.XCreateSimpleWindow(
            self.display,
            self.root_win,
            0, // x
            0, // y
            640, // width
            480, // height
            1, // border_width
            white, // border color
            black, // background color
        );

        const win = Window{
            .handle = handle,
            .target = self,
        };

        if (c.XMapRaised(self.display, win.handle) == 0) {
            return XErr.MapWin;
        }

        try self.flush();

        return win;
    }

    pub fn deinit(self: Target) void {
        if (c.XCloseDisplay(self.display) == 0) {
            std.log.warn("failed to close connection to Xserver", .{});
        }
    }

    pub fn flush(self: Target) XErr!void {
        if (c.XFlush(self.display) == 0) {
            return XErr.Flush;
        }
    }
};

inline fn initDisplay() XErr!*c.Display {
    const display = c.XOpenDisplay(null) orelse return XErr.OpenDisplay;

    if (c.XNoOp(display) == 0) {
        return XErr.NoopCmd;
    }

    return display;
}
