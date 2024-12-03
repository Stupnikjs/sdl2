// cli interface builder
const std = @import("std");
const string = @import("string.zig");
const strequal = std.mem.eql;

pub fn ParseUserInput(commandBuffer: []u8) !usize {
    const stdin = std.io.getStdIn().reader();
    const command = try stdin.read(commandBuffer);
    return command;
}

pub fn ParseCommand(cmdStr: []const u8) !void {
    const splited = try string.splitSpace(cmdStr, std.heap.page_allocator);
    _ = splited;
}

// extract args are strings
// list takes one arg instrument or effect
// init takes one arg that is the sample len in milliseconds
