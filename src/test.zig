const std = @import("std");
const testing = std.testing;
const expect = testing.expect;
const sdl = @import("sdl.zig");

test "sdl load wav" {
    var spec: sdl.SDL.SDL_AudioSpec = undefined;
    var audio_buf: [*c]u8 = undefined;
    var len: u32 = undefined;
    const sp = sdl.SDL.SDL_LoadWAV("./samples/test.wav", &spec, &audio_buf, &len);
    std.debug.print("{d}", .{audio_buf[0..100]});
    spec.channels = 2;
    _ = sp;
    try sdl.SDL_PlayBuffer(audio_buf, spec, len);
}
