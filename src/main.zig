const std = @import("std");
const tobytes = @import("int.zig").intToBytes;
const buildSin = @import("int.zig").buildSin;
const api = @import("sdl.zig");

pub fn main() !void {
    try api.PlayAudio(5, 440, 11100);
}
