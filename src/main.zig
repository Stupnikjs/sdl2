const std = @import("std");
const tobytes = @import("int.zig").intToBytes;
const buildSin = @import("int.zig").buildSin;
const wrapper = @import("wrapper.zig");

pub fn main() !void {
    try wrapper.PlayAudio(1, 440.00);
    try wrapper.PlayAudio(1, 340.00);
    try wrapper.PlayAudio(2, 640.00);
    try wrapper.PlayAudio(1, 440.00);
    try wrapper.PlayAudio(2, 340.00);
    try wrapper.PlayAudio(1, 640.00);
}
