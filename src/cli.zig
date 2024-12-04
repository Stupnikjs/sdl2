// cli interface builder
const std = @import("std");
const string = @import("string.zig");
const strequal = std.mem.eql;

pub const Command = enum { exit, help, list, gen, play, init, reset, save };

pub fn ParseCommand(cmdStr: []const u8) !void {
    const allocator = std.heap.page_allocator;
    const trimedLeft = try string.trimLeft(cmdStr, allocator);
    const trimed = try string.trimRight(trimedLeft, allocator);

    const splited = try string.splitSpace(trimed, allocator);

    std.debug.print("splited {s} \n", .{splited});

    const command: Command = try GetCommand(splited[0]);

    switch (command) {
        .exit => std.process.exit(1),
        .help => helpFunc(),
        .gen => try genSound(splited[1..], allocator),
        else => std.debug.print("something wrong happened", .{}),
    }
}

pub fn GetCommand(str: []const u8) !Command {
    if (strequal(u8, str, "exit")) return Command.exit;
    if (strequal(u8, str, "help")) return Command.help;
    if (strequal(u8, str, "init")) return Command.init;
    if (strequal(u8, str, "play")) return Command.play;
    if (strequal(u8, str, "reset")) return Command.reset;
    if (strequal(u8, str, "gen")) return Command.gen;
    if (strequal(u8, str, "reset")) return Command.reset;
    return error.CommandMalformed;
}

pub fn helpFunc() void {
    std.debug.print("printing help", .{});
}

pub fn genSound(buffer: []u8, args: [][]const u8, allocator: std.mem.Allocator) !void {
    var map = std.StringHashMap([]const u8).init(allocator);
    if (@mod(args.len, 2) != 0) return error.CommandMalformed;
    for (0..args.len / 2) |i| {
        if (args[i * 2][0] == '-') {
            try map.put(args[i * 2], args[i * 2 + 1]);
        }
    }
    soundFromMap(buffer, map);
}

pub fn soundFromMap(buffer: []u8, map: std.StringHashMap([]const u8)) !void {
    _ = buffer;
    _ = map;
}
// extract args are strings
// list takes one arg instrument or effect
// init takes one arg that is the sample len in milliseconds
