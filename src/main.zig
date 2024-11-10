const std = @import("std");
const tobytes = @import("types.zig").intToBytes;
const api = @import("sdl.zig");
const types = @import("types.zig");

pub fn main() !void {
    const params = types.SoundParams.init(44100, 440, 1024, 10000);
    try api.PlayAudio(params);
    try api.PlayAudio(params);
    try api.PlayAudio(params);
}
