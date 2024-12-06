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
    const stdin = std.io.getStdIn().reader();
    var audioBuff = try allocator.alloc(u8, 2048 * 4);
    var params = SoundParams.init(
        44100,
        1024,
        3000,
        440,
        types.Instrument.sinWave,
        allocator,
    );
    // [*] for fixed size array
    while (true) {
        std.debug.print(":> ", .{});
        const cmdStr = try stdin.readUntilDelimiter(buffer, '\n');
        try cli.ParseCommand(cmdStr, &audioBuff, &params);
    }
}
