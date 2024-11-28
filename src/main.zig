const std = @import("std");
const sdl = @import("sdl.zig");
const ui = @import("ui.zig");
const types = @import("types.zig");
const SoundParams = types.SoundParams;
const SDL = @import("sdl.zig").SDL;
const PlayBuffer = @import("sdl.zig").PlayBuffer;
const wav = @import("wav.zig");
const buf = @import("buf.zig");

pub fn main() !void {
    var buffA = try buildRandomBuf();
    var allocator = std.heap.page_allocator;
    var buff16 = try allocator.alloc(i16, buffA.len / 2);
    for (0..buffA.len / 2) |i| {
        buff16[i] = ui.sampleExtract(buffA[i * 2 .. i * 2 + 2]);
    }
    const newBuff = try buf.normalizeBuff(i16, buff16, std.heap.page_allocator, 300);
    try ui.uiWrapper(i16, newBuff[0..]);
}

// Track avec 16 Temps
// une track par instrument

pub fn buildRandomBuf() ![]u8 {
    var Asin: types.Note = types.Note.init(types.Instrument.sinWave, 200, false);
    var seq = try Asin.PlayRange(false, std.heap.page_allocator);
    const paramsA = types.SoundParams.init(44100, 1024, std.heap.page_allocator);
    return try sdl.buildBuffer(paramsA, seq[0..]);
}
