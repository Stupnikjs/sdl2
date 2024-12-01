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

pub fn main() !void {
    const paramsA = types.SoundParams.init(44100, 1024, std.heap.page_allocator);
    var Asin: types.Note = types.Note.init(types.Instrument.sinWave, 200, false);
    const seq = try Asin.PlayRange(false, std.heap.page_allocator);
    const buffer_audio = try sdl.buildBuffer(paramsA, seq);
    _ = buffer_audio;
    var commandBuffer = try paramsA.allocator.alloc(u8, 2048);
    var bufferAudio:[]u8 = undefined;

    while (true) {
        std.debug.print(":>", .{});
        const len = try cli.ParseUserInput(commandBuffer);
        std.debug.print("{s}", .{commandBuffer[0..len]});
        const command = try cli.Parser(commandBuffer[0..len], bufferAudio, paramsA.allocator);

        std.debug.print("{any} \n", .{command});
    }
}
