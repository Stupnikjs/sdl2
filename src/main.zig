const std = @import("std");
const tone = @import("tone.zig");

// each track has a sequence
// u select instruments
// each instruments can have effect

pub fn main() !void {
    try tone.playFull(440);
}
