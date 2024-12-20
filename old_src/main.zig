const std = @import("std");
const sdl = @import("./sdl/sdl.zig");
const cli = @import("cli.zig");
const types = @import("types.zig");
const SoundParams = types.SoundParams;
const audio = @import("audio.zig");
const SDL = sdl.SDL;
const PlayBuffer = @import("/sdl/sdl.zig").PlayBuffer;
const wav = @import("./util/wav.zig");
const buf = @import("./util/buf.zig");
const string = @import("./util/string.zig");

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
        cli.ParseCommand(cmdStr, &audioBuff, &params) catch |err| {
            if (err == error.CommandMalformed) std.debug.print("Command is malformed \n", .{});
        };
    }
}
