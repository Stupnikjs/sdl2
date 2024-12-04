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
        if (c != ' ' and c != '\n' and c != 13 and !started) started = true;
        if (started) {
            try list.append(c);
        }
    }
    return list.toOwnedSlice();
}

pub fn reverseString(str: []const u8, allocator: std.mem.Allocator) ![]const u8 {
    var list = std.ArrayList(u8).init(allocator);
    var i = str.len;
    while (i > 0) {
        try list.append(str[i - 1]);
        i -= 1;
    }
    return list.toOwnedSlice();
}

pub fn trimRight(str: []const u8, allocator: std.mem.Allocator) ![]const u8 {
    const reversed = try reverseString(str, allocator);
    defer allocator.free(reversed);
    const trimed = try trimLeft(reversed, allocator);
    defer allocator.free(trimed);
    const rereversed = try reverseString(trimed, allocator);
    return rereversed;
}

pub fn trimSpace(str: []const u8, allocator: std.mem.Allocator) ![]const u8 {
    const trimedLeft = try trimLeft(str, allocator);
    defer allocator.free(trimedLeft);
    const trimed = try trimRight(trimedLeft, allocator);
    return trimed;
}
