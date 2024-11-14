const std = @import("std");
const tone = @import("tone.zig");
const input = @import("input.zig");

// each track has a sequence
// u select instruments
// each instruments can have effect

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const in = try input.parseInput(allocator);
    const arrNote = try input.inputToNote(in, allocator, 440);
    std.debug.print(":> input {any}", .{arrNote});
}
