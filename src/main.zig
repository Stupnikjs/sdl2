const std = @import("std");
const sdl = @import("sdl.zig");
const ui = @import("ui.zig");
const types = @import("types.zig");
const SoundParams = types.SoundParams;
const SDL = @import("sdl.zig").SDL;
const PlayBuffer = @import("sdl.zig").PlayBuffer;

pub fn main() !void {

    // Initialize SDL
    const Asin: types.Note = types.Note.init(types.Instrument.sinWave, 440);
    const Bsin: types.Note = types.Note.init(types.Instrument.sinWave, types.getNoteFactor(440, 2));
    var seq = [1]types.Note{Asin};
    var seq1 = [1]types.Note{Bsin};
    const paramsA = types.SoundParams.init(44100, 1024, std.heap.page_allocator);
    const paramsB = types.SoundParams.init(44100, 1024, std.heap.page_allocator);
    const buffA = try sdl.buildBuffer(paramsA, seq[0..]);
    const buffB = try sdl.buildBuffer(paramsB, seq1[0..]);

    var arr: [2][]u8 = [2][]u8{ buffA, buffB };
    std.time.sleep(1000);
    try ui.uiWrapper(arr[0..]);
}

//
