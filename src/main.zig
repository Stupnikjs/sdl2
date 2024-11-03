const std = @import("std");
const tobytes = @import("int.zig").intToBytes;
const buildSin = @import("int.zig").buildSin;
const api = @import("sdl.zig");

pub fn main() !void {
    for (0..4) |i| {
        try api.PlayAudio(1, 440 * i, 66100);
    }
}
