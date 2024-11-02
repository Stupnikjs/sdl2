const std = @import("std");
const tobytes = @import("int.zig").intToBytes;
const buildSin = @import("int.zig").buildSin;
const wrapper = @import("wrapper.zig");

pub fn main() !void {
    // cant play higer thant one second
    try wrapper.PlayAudio(3, 540.00, 8000);
}
