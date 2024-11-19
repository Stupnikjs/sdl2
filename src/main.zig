const std = @import("std");
const tone = @import("tone.zig");
const input = @import("input.zig");
const sdl = @import("sdl.zig");
const types = @import("types.zig");
const SoundParams = types.SoundParams;
// each track has a sequence
// u select instruments
// each instruments can have effect

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var in = try input.parseInput(allocator);
    while (true) {
        const arrNote = try input.inputToNote(in, allocator, 440);
        const params = SoundParams.init(44100, 1024, allocator);
        try sdl.PlayAudio(params, arrNote);
        in = try input.parseInput(allocator);
    }
}
