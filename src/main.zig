const std = @import("std");
const tobytes = @import("int.zig").intToBytes;
const buildSin = @import("int.zig").buildSin;
const api = @import("sdl.zig");
const types = @import("types.zig");

pub fn main() !void {
    const params = types.SoundParams.init(44100, 440, 4096, 4000);
    const seq = try types.MusicSeq.init(6, std.heap.page_allocator);
    try api.PlayAudio(seq, params);
}
