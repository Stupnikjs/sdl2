const std = @import("std");

pub fn splitSpace(str: []const u8, allocator: std.mem.Allocator) ![][]const u8 {
    var list = std.ArrayList(u8).init(allocator);
    var res_list = std.ArrayList([]const u8).init(allocator);
    for (str, 0..str.len) |c, i| {
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

pub fn trimLeft(str: []const u8, allocator: std.mem.Allocator) ![]const u8 {
    var list = std.ArrayList(u8).init(allocator);
    var started = false;
    for (str) |c| {
        if (c != ' ' and !started) started = true;
        if (started) {
            try list.append(c);
        }
    }
    return list.toOwnedSlice();
}

pub fn trimRight(str: []const u8, allocator: std.mem.Allocator) ![]const u8 {
    var list = std.ArrayList(u8).init(allocator);
    var result = std.ArrayList(u8).init(allocator);
    var started = false;
    var i = str.len;
    while (i > 0) {
        if (str[i - 1] != ' ' and !started) started = true;
        if (started) try list.append(str[i - 1]);
        i -= 1;
    }

    i = list.items.len;
    while (i > 0) {
        try result.append(list.items[i - 1]);
        i -= 1;
    }
    list.deinit();
    return result.toOwnedSlice();
}
