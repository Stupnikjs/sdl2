const std = @import("std");
const sdl = @import("sdl.zig");
const ui = @import("ui.zig");
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
    try ui.uiWrapper(buffer_audio, paramsA);
}
