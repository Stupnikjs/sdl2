const std = @import("std");
const sdl = @import("sdl.zig");
const cli = @import("cli.zig");
const types = @import("types.zig");
const SoundParams = types.SoundParams;
const audio = @import("audio.zig");
const SDL = @import("sdl.zig").SDL;
const PlayBuffer = @import("sdl.zig").PlayBuffer;
const wav = @import("wav.zig");
const buf = @import("buf.zig");
const string = @import("string.zig");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const buffer = try allocator.alloc(u8, 1024);
    while (true) {
        std.debug.print(":>", .{});

        const len = try cli.ParseUserInput(buffer);
        const arr = try string.splitSpace(buffer[0..len], allocator);
        std.debug.print("{s} \n", .{arr});
    }
}
