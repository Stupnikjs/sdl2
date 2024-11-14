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
    std.debug.print(":> input {s}", .{in});
    std.debug.print(":> input  \n", .{});
}
