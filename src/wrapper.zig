const std = @import("std");
const math = std.math;
const tobytes = @import("int.zig").intToBytes;
const buildSin = @import("int.zig").buildSin;
const types = @import("types.zig");
const bufferError = types.bufferError;

const SDL = @cImport({
    @cInclude("SDL2/SDL.h");
});

pub var audio_pos: ?[*]u8 = null; // Pointer to the audio buffer.
pub var audio_len: usize = 0; // Remaining length of the sample to play.

fn my_audio_callback(ctx: ?*anyopaque, stream: [*c]u8, len: c_int) callconv(.C) void {
    _ = ctx;
    // Accessing global variables audio_pos and audio_len
    if (audio_len == 0) return;
    const len_usize: usize = @intCast(len);
    const audio_len_usize: usize = @intCast(audio_len);
    const length = if (len > audio_len) audio_len_usize else len_usize;
    const audio_cast: [*c]u8 = @ptrCast(audio_pos);
    _ = SDL.SDL_memcpy(stream, audio_cast, length); // Copy audio data to stream
    audio_pos.? += length;
    audio_len -= length;
}

fn sdlPanic() noreturn {
    const str = @as(?[*:0]const u8, SDL.SDL_GetError()) orelse "unknown error";
    @panic(std.mem.sliceTo(str, 0));
}

pub fn InitSpec(freq: usize, samples: u16) SDL.SDL_AudioSpec {
    const freq_c: c_int = @intCast(freq);

    return .{
        .freq = freq_c,
        .format = SDL.AUDIO_S16,
        .channels = 1,
        .samples = samples,
        .callback = my_audio_callback,
        .userdata = null,
    };
}

pub fn PlayAudio(sec: usize) !void {
    const samples: u16 = 400;
    var audioSpec = InitSpec(44100, samples);
    if (SDL.SDL_Init(SDL.SDL_INIT_VIDEO | SDL.SDL_INIT_EVENTS | SDL.SDL_INIT_AUDIO) < 0)
        sdlPanic();
    defer SDL.SDL_Quit();

    const allocator = std.heap.page_allocator;

    const freq_usize: u32 = @intCast(audioSpec.freq);
    audio_len = freq_usize * sec; // 10 is sec

    const buffer = try allocator.alloc(u8, audio_len);
    defer allocator.free(buffer);

    try sinCreator(buffer, freq_usize);
    audio_pos = buffer.ptr;

    _ = SDL.SDL_OpenAudio(&audioSpec, null);
    const err = SDL.SDL_GetError();
    std.debug.print("SDL_Open audio failled {d}", .{err.*});
    SDL.SDL_PauseAudio(0);
    while (audio_len > 100) {
        SDL.SDL_Delay(100);
    }
    SDL.SDL_CloseAudio();
    _ = SDL.SDL_Quit();
}

// a slice is a pointer
pub fn sinCreator(buffer: []u8, sr: u32) bufferError!void {
    if (buffer.len % 2 != 0) return bufferError.invalidLength;
    for (0..buffer.len / 2) |i| {
        const sr_f64: f64 = @floatFromInt(sr);
        const if64: f64 = @floatFromInt(i);
        const sin: f64 = @sin(2 * math.pi * if64 * 1000 / sr_f64) + 1;
        const int16: u16 = @intFromFloat(@trunc(sin));
        const bytes = tobytes(u16, int16);
        buffer[i * 2] = bytes[0];
        buffer[i * 2 + 1] = bytes[1];
    }
    return;
}

pub fn bufferToCSV(buffer: []u8) bufferError!void {
    if (buffer.len % 2 != 0) return bufferError.invalidLength;
    const file = try std.fs.cwd().openFile("buf.csv", .{});

    for (0..buffer.len / 2) |i| {
        const buff = buffer[i * 2 .. i * 2 + 1];
        const sample = std.mem.readInt(i16, buff);
        // to string
        try file.write(std.fmt);
    }
}
