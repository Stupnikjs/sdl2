const std = @import("std");
const sdl = @import("sdl.zig");
const types = @import("types.zig");
const cli = @import("cli.zig");
const testing = std.testing;
const expect = testing.expect;
const wav = @import("wav.zig");
const buf = @import("buf.zig");
const string = @import("string.zig");

test "trim right" {
    const allocator = std.heap.page_allocator;
    const simple = try string.trimRight("  nosp  ", allocator);
    try expect(std.mem.eql(u8, simple, "  nosp"));
    //allocator.free(splited);
}
test "trim left" {
    const allocator = std.heap.page_allocator;
    const simple = try string.trimLeft("  nosp", allocator);
    std.debug.print("|{s}|", .{simple});
    try expect(std.mem.eql(u8, simple, "nosp"));
    //allocator.free(splited);
}
test "trim right hard" {
    const allocator = std.heap.page_allocator;
    const simple = try string.trimRight(" nosp uzzu ", allocator);
    try expect(std.mem.eql(u8, simple, " nosp uzzu"));
    try expect(simple.len == 10);
    //allocator.free(splited);
}

test "trim both" {
    const allocator = std.heap.page_allocator;
    const simple = try string.trimSpace(" nospuzzu ", allocator);
    try expect(std.mem.eql(u8, simple, "nospuzzu"));
    try expect(simple.len == 8);
    //allocator.free(splited);
}

test "trim right SIMPLE" {
    const allocator = std.heap.page_allocator;
    const simple = try string.trimRight("nospuzzu ", allocator);
    try expect(std.mem.eql(u8, simple, "nospuzzu"));
    try expect(simple.len == 8);
    //allocator.free(splited);
}
test "trim left SIMPLE" {
    const allocator = std.heap.page_allocator;
    const simple = try string.trimLeft(" nospuzzu", allocator);
    std.debug.print("simple  |{s}| \n", .{simple});
    try expect(std.mem.eql(u8, simple, "nospuzzu"));
    try expect(simple.len == 8);
    //allocator.free(splited);
}

test "sld play" {
    const params = types.SoundParams.init(
        44100,
        1024,
        3000,
        440,
        types.Instrument.sinWave,
        std.heap.page_allocator,
    );
    const buffer = try sdl.buildBuffer(params);
    try sdl.SDL_PlayBuffer(buffer, params);
    try sdl.SDL_PlayWav("file.wav");
}

test "split space" {
    const splited = try string.splitSpace("hello world from here", std.heap.page_allocator);
    try expect(splited.len == 4);
    try expect(std.mem.eql(u8, splited[3], "here"));
}
