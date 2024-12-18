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

// test "basic play wav" {
//     const start = std.time.microTimestamp();
//     var allocator = std.heap.page_allocator;
//     // reads header and prints values
//     const buff = try wav.bufferFromWav("./samples/hip_hop_kick.wav", allocator);

//     var maxi_buff = try allocator.alloc(u8, sdl.fixed_len);
//     @memcpy(maxi_buff[2084 .. buff.len + 2084], buff);

//     try sdl.SDL_PlayBuffer(maxi_buff.ptr, true);
//     const end = std.time.microTimestamp();

//     std.debug.print("time {d} \n", .{end - start});
// }

// test "spec play sound" {
//     // var allocator = std.heap.page_allocator;
//     const buff = try sdl.buildBuffer();
//     var spec = sdl.InitSpec(44100, sdl.SDL.AUDIO_U16, 1, 2048, true);
//     try sdl.SDL_PlayBuffer(buff.ptr, &spec);
// }

// test "play wav" {
//     var allocator = std.heap.page_allocator;
//     const buff = try wav.OpenWAVFileAllocated("./samples/test.wav", allocator);
//     const header = try wav.WavHeader.deserializeHeader(buff, allocator);
//     header.PrintHeader();
//     try header.Play(buff);
//     defer allocator.free(buff);
// }

test "sdl load wav" {
    try sdl.SDL_PlayBuffer();
}
