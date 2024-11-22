const std = @import("std");
const input = @import("input.zig");
const sdl = @import("sdl.zig");
const ui = @import("ui.zig");
const types = @import("types.zig");
const SoundParams = types.SoundParams;
const SDL = @import("sdl.zig").SDL;
const PlayAudio = @import("sdl.zig").PlayAudio;

pub fn main() !void {
    // Initialize SDL
    // to long to build the buffer
    // need to create it at launch

    //try ui.uiWrapper();
    try testNote();
}

pub fn testNote() !void {
    const Asin: types.Note = types.Note.init(types.Instrument.sinWave, 440);
    var seq = [1]types.Note{Asin};
    const params = types.SoundParams.init(44100, 1024, std.heap.page_allocator);
    const buff = try sdl.buildBuffer(params, seq[0..]);
    try PlayAudio(buff, params);
}
