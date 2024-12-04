// cli interface builder
const std = @import("std");
const string = @import("string.zig");
const strequal = std.mem.eql;
const sdl = @import("sdl.zig");

pub const Command = enum { exit, help, list, gen, play, init, save };

pub fn ParseCommand(cmdStr: []const u8, buffer: *[]u8) !void {
    const allocator = std.heap.page_allocator;
    const trimedLeft = try string.trimLeft(cmdStr, allocator);
    const trimed = try string.trimRight(trimedLeft, allocator);
    // test here for no args command (exit)
    const splited = try string.splitSpace(trimed, allocator);

    const command: Command = try GetCommand(splited[0]);

    switch (command) {
        .exit => std.process.exit(1),
        .help => helpFunc(),
        .gen => try genSound(buffer, splited[1..], allocator),
        .init => try initFunc(buffer, allocator),
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

pub fn genSound(buffer: *[]u8, args: [][]const u8, allocator: std.mem.Allocator) !void {
    var map = std.StringHashMap([]const u8).init(allocator);
    if (@mod(args.len, 2) != 0) return error.CommandMalformed;
    for (0..args.len / 2) |i| {
        if (args[i * 2][0] == '-') {
            try map.put(args[i * 2], args[i * 2 + 1]);
        }
    }
    try soundFromMap(buffer, map);
}

// needs buffer len to call sound making func
pub fn soundFromMap(buffer: *[]u8, map: std.StringHashMap([]const u8)) !void {
    buffer.* = sdl.buildBuffer(params, seq);
    _ = map;
}

pub fn initFunc(buffer: *[]u8, allocator: std.mem.Allocator) !void {
    const new = try allocator.alloc(u8, 2048);
    buffer.* = new;
}
// extract args are strings
// list takes one arg instrument or effect
// init takes one arg that is the sample len in milliseconds
