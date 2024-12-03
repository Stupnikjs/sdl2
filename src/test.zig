const std = @import("std");
const sdl = @import("sdl.zig");
const types = @import("types.zig");
const cli = @import("cli.zig");
const testing = std.testing;
const expect = testing.expect;
const wav = @import("wav.zig");
const buf = @import("buf.zig");
const string = @import("string.zig");

test "split space" {
    const allocator = std.heap.page_allocator;
    const simple = try string.splitSpace("nospace BUT wait here some space ", allocator);
    std.debug.print("{s}", .{simple});
    try expect(simple.len == 6);
    //allocator.free(splited);
}

test "trim right" {
    const allocator = std.heap.page_allocator;
    const simple = try string.trimRight("nosp  ", allocator);
    try expect(std.mem.eql(u8, simple, "nosp"));
    //allocator.free(splited);
}
