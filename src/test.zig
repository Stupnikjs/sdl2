const std = @import("std");
const sdl = @import("sdl.zig");
const types = @import("types.zig");
const cli = @import("cli.zig");
const testing = std.testing;
const expect = testing.expect;
const wav = @import("wav.zig");
const buf = @import("buf.zig");

test "split space" {
    const allocator = std.heap.page_allocator;
    const splited = try cli.splitSpace("mem mem mem", allocator);
    defer allocator.free(splited);
    std.debug.print("splited {s} \n", .{splited});
    try (expect(splited.len == 3));
}
