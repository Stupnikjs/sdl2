const std = @import("std");
const sdl = @import("sdl.zig");
const types = @import("types.zig");
const ui = @import("ui.zig");
const testing = std.testing;
const expect = testing.expect;
const wav = @import("wav.zig");

test "wav writefile" {
    // Initialize SDL

    // pass effect to buff A
    //const u32_buffer_size: u32 = @intCast(buffA.len);
    //var header = wav.WavHeader.init(u32_buffer_size);
    //var filename = [_]u8{ 'h', 'e', '.', 'w', 'a', 'v' };
    // try header.WriteWav(buffA, &filename);
    // try types.bufferToCSV(buffA);

}

test "ui BUFFER PLOT" {
    var buffA = [_]u8{
        1,  4,  40, 59, 59, 40, 40, 1,  4,  40, 59, 59, 40, 40, 1,  4,  40, 59, 59, 40, 40, 1,  4,  40,
        59, 59, 40, 40, 1,  4,  40, 59, 59, 40, 40, 1,  4,  40, 59, 59, 40, 40, 1,  4,  40, 59, 59, 40,
        40, 1,  4,  40, 59, 59, 40, 40, 1,  4,  40, 59, 59, 40, 40, 1,  4,  40, 59, 59, 40, 40, 40, 1,
        4,  40, 59, 59, 40, 40, 1,  4,  40, 59, 59, 40, 40, 1,  4,  40, 59, 59, 40, 40, 4,  40, 59, 59,
        40, 40, 1,  4,  40, 59, 59, 40, 40, 1,  4,  40, 59, 59, 40, 40, 1,  4,  40, 59, 59, 40, 40, 1,
        4,  40, 59, 59, 40, 40, 1,  4,  40, 59, 59, 40, 40, 1,  4,  40, 59, 59, 40, 40, 1,  4,  40, 59,
        59, 40, 40, 1,  4,  40, 59, 59, 40, 40, 1,  4,  40, 59, 59, 40, 40, 40, 1,  4,  40, 59, 59, 40,
        40, 1,  4,  40, 59, 59, 40, 40, 1,  4,  40, 59, 59, 40, 40,
    };
    try ui.uiWrapper(buffA[0..]);
}

pub fn buildRandomBuf() ![]u8 {
    var Asin: types.Note = types.Note.init(types.Instrument.sinWave, 200, false);
    var seq = try Asin.PlayRange(false, std.heap.page_allocator);
    const paramsA = types.SoundParams.init(44100, 1024, std.heap.page_allocator);
    return try sdl.buildBuffer(paramsA, seq[0..]);
}
