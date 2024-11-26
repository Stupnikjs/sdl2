const std = @import("std");
const sdl = @import("sdl.zig");
const types = @import("types.zig");
const testing = std.testing;
const expect = testing.expect;
const wav = @import("wav.zig");

test "wav writefile" {
    // Initialize SDL
    var Asin: types.Note = types.Note.init(types.Instrument.sinWave, 200);
    var seq = try Asin.PlayRange(false, std.heap.page_allocator);
    const paramsA = types.SoundParams.init(44100, 1024, std.heap.page_allocator);
    const buffA = try sdl.buildBuffer(paramsA, seq[0..]);
    // pass effect to buff A 
    const u32_buffer_size: u32 = @intCast(buffA.len);
    var header = wav.WavHeader.init(u32_buffer_size);
    var filename = [_]u8{ 'h', 'e', '.', 'w', 'a', 'v' };
    try header.WriteWav(buffA, &filename);
}
