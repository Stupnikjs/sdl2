// cli interface builder
const std = @import("std");
const string = @import("string.zig");
const strequal = std.mem.eql;
const sdl = @import("sdl.zig");
const wav = @import("wav.zig");
const types = @import("types.zig");

pub const Command = enum { exit, help, list, gen, play, init, save };

pub fn ParseCommand(cmdStr: []const u8, buffer: *[]u8, params: *types.SoundParams) !void {
    const allocator = std.heap.page_allocator;
    const trimedLeft = try string.trimLeft(cmdStr, allocator);
    const trimed = try string.trimRight(trimedLeft, allocator);
    const splited = try string.splitSpace(trimed, allocator);
    const command: Command = try GetCommand(splited[0]);

    switch (command) {
        .exit => std.process.exit(1),
        .help => helpFunc(),
        .play => try playFunc(buffer.*, splited[1..], params.*),
        .gen => try genSound(buffer, splited[1..], params, allocator),
        .init => try initFunc(buffer, allocator),
        .save => try saveFunc(buffer.*, splited[1..]),
        else => std.debug.print("something wrong happened", .{}),
    }
}

pub fn GetCommand(str: []const u8) !Command {
    if (strequal(u8, str, "exit")) return Command.exit;
    if (strequal(u8, str, "help")) return Command.help;
    if (strequal(u8, str, "init")) return Command.init;
    if (strequal(u8, str, "play")) return Command.play;
    if (strequal(u8, str, "gen")) return Command.gen;
    if (strequal(u8, str, "save")) return Command.save;
    return error.CommandMalformed;
}

pub fn helpFunc() void {
    const helpMsg = "Here is help msg";
    std.debug.print("{s} \n", .{helpMsg});
}

pub fn genSound(buffer: *[]u8, args: [][]const u8, params: *types.SoundParams, allocator: std.mem.Allocator) !void {
    var map = std.StringHashMap([]const u8).init(allocator);
    // if (@mod(args.len, 2) != 0) return error.CommandMalformed; print wrong arg or smthing
    for (0..args.len / 2) |i| {
        if (args[i * 2][0] == '-') {
            try map.put(args[i * 2], args[i * 2 + 1]);
        }
    }
    try soundFromMap(buffer, map, params);
}

// needs buffer len to call sound making func

pub fn paramsFromMap(map: std.StringHashMap([]const u8), params: *types.SoundParams) !void {
    // last char of command being ignored
    if (map.get("-i") != null) {
        std.debug.print("{s}", .{map.get("-i").?});
        params.instrument = types.Instrument.sinWave;
    }
    if (map.get("-f") != null) {
        std.debug.print("f:{s} \n", .{map.get("-f").?});
        const freq: f64 = try std.fmt.parseFloat(f64, map.get("-f").?);
        std.debug.print("{s} \n", .{map.get("-f").?});
        params.frequency = freq;
    } else return error.CommandMalformed;
}

pub fn soundFromMap(buffer: *[]u8, map: std.StringHashMap([]const u8), params: *types.SoundParams) !void {
    // func paramsFromMap
    try paramsFromMap(map, params);
    buffer.* = try sdl.buildBuffer(params.*);
}

pub fn initFunc(buffer: *[]u8, allocator: std.mem.Allocator) !void {
    const new = try allocator.alloc(u8, 2048);
    buffer.* = new;
}
// extract args are strings
// list takes one arg instrument or effect
// init takes one arg that is the sample len in milliseconds

pub fn playFunc(buffer: []u8, args: [][]const u8, params: types.SoundParams) !void {
    const map = try mapFormArgs(args, params.allocator);
    if (map.get("-f") != null) {
        try sdl.SDL_PlayWav(map.get("-f").?);
    }
    try sdl.SDL_PlayBuffer(buffer, params);
}

pub fn saveFunc(buffer: []u8, args: [][]const u8) !void {
    const allocator = std.heap.page_allocator;
    const map = try mapFormArgs(args, allocator);

    var name: []const u8 = undefined;
    if (map.get("-f") == null) return error.CommandMalformed else name = map.get("-f").?;
    const len: u32 = @intCast(buffer.len);
    var header = wav.WavHeader.init(len);
    try header.WriteWav(buffer, name);
    // allocator.free(map);
}

pub fn mapFormArgs(args: [][]const u8, allocator: std.mem.Allocator) !std.StringHashMap([]const u8) {
    var map = std.StringHashMap([]const u8).init(allocator);
    // if (@mod(args.len, 2) != 0) return error.CommandMalformed; print wrong arg or smthing
    for (0..args.len / 2) |i| {
        if (args[i * 2][0] == '-') {
            try map.put(args[i * 2], args[i * 2 + 1]);
        }
    }
    return map;
}
