const std = @import("std");
const testing = std.testing;
const expect = testing.expect;
const sdl = @import("sdl.zig");
const sound = @import("sound.zig");
const wav = @import("wav.zig");

// test "basic audio loop" {
//     const start = std.time.microTimestamp();
//     const buffer = try sdl.buildBuffer();
//     try sdl.SDL_PlayBuffer(buffer.ptr, true);

//     const end = std.time.microTimestamp();

//     std.debug.print("time {d} \n", .{end - start});
// }

test "basic play wav" {
    const start = std.time.microTimestamp();
    var allocator = std.heap.page_allocator;
    const buff = try wav.bufferFromWav("kick.wav", allocator);
    var maxi_buff = try allocator.alloc(u8, sdl.fixed_len);
    @memcpy(maxi_buff[2084 .. buff.len + 2084], buff);

    try sdl.SDL_PlayBuffer(maxi_buff.ptr, true);
    const end = std.time.microTimestamp();

    std.debug.print("time {d} \n", .{end - start});
}
