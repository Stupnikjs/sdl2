const std = @import("std");
const tone = @import("tone.zig");

pub fn main() !void {
    try tone.playFull(440);
}
