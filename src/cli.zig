// cli interface builder
const std = @import("std");
const strequal = std.mem.eql;

pub fn ParseUserInput(commandBuffer: []u8) !usize {
    const stdin = std.io.getStdIn().reader();
    const command = try stdin.read(commandBuffer);
    return command;
}

pub fn splitSpace(str: []const u8, allocator: std.mem.Allocator) ![][]const u8 {
    var list = std.ArrayList(u8).init(allocator);
    var res_list = std.ArrayList([]const u8).init(allocator);
    for (str) |c| {
        if (c == '\n' or c == 13) {
            try res_list.append(list.items);
            list.clearAndFree();
            break;
        }
        if (c == ' ' and list.items.len > 0) {
            try res_list.append(list.items);
            list.clearAndFree();
            list = std.ArrayList(u8).init(allocator);
        }
        try list.append(c);
        std.debug.print("{s} \n", .{list.items});
    }
    // list.deinit();
    return res_list.items;
}

// extract args are strings
// list takes one arg instrument or effect
// init takes one arg that is the sample len in milliseconds
