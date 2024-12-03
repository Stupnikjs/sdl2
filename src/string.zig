const std = @import("std");

pub fn splitSpace(str: []const u8, allocator: std.mem.Allocator) ![][]const u8 {
    var list = std.ArrayList(u8).init(allocator);
    var res_list = std.ArrayList([]const u8).init(allocator);
    for (str, 0..str.len) |c, i| {
        std.debug.print("{c} \n", .{c});
        if (i == str.len - 1) {
            try res_list.append(try list.toOwnedSlice());
            break;
        }
        if (c == ' ' and list.items.len > 0) {
            try res_list.append(try list.toOwnedSlice());
            list = std.ArrayList(u8).init(allocator);
        } else {
            try list.append(c);
        }
    }
    return res_list.items;
}
