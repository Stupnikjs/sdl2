const std = @import("std");
const tobytes = @import("int.zig").intToBytes;
const buildSin = @import("int.zig").buildSin;

const SDL = @cImport({
    @cInclude("SDL2/SDL.h");
});

var audio_pos: ?[*]u8 = null; // Pointer to the audio buffer.
var audio_len: usize = 0; // Remaining length of the sample to play.

pub fn generate_sine_wave(audio_buff: *[]u8, frequency: u32, sample_rate: c_int) void {
    const two_pi = 2.0 * std.math.pi;
    const amplitude: u8 = 127; // Half of 255, to center the wave
    const offset: u8 = 128; // Offset to shift wave into u8 range

    // Fill the buffer with sine wave values
    for (audio_buff, 0..audio_len) |*sample, i| {
        // Calculate the angle for the sine wave at this sample index
        const float_i: f64 = @floatFromInt(i);
        const float_freq: f64 = @floatFromInt(frequency);
        const sample_rate_float: f64 = @floatFromInt(sample_rate);
        const theta = (two_pi * float_freq * float_i) / sample_rate_float;
        // Compute sine value, scale to [0, 255] range, and convert to u8
        const value: u8 = @intCast(amplitude * std.math.sin(theta) + offset);
        sample.* = value;
    }
}

pub fn main() !void {
    if (SDL.SDL_Init(SDL.SDL_INIT_VIDEO | SDL.SDL_INIT_EVENTS | SDL.SDL_INIT_AUDIO) < 0)
        sdlPanic();
    defer SDL.SDL_Quit();
    const allocator = std.heap.page_allocator;

    // generate basic audio params
    var audioSpec: SDL.SDL_AudioSpec = InitSpec();

    const freq_usize: u32 = @intCast(audioSpec.freq);

    audio_len = freq_usize * 100; // 10 is sec

    const buffer = try allocator.alloc(u8, audio_len);

    for (0..audio_len) |i| {
        buffer[i] = tobytes(usize, i)[0];
    }

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

pub fn InitSpec() SDL.SDL_AudioSpec {
    return .{
        .freq = 44100,
        .format = SDL.AUDIO_S16,
        .channels = 1,
        .samples = 4096,
        .callback = my_audio_callback,
        .userdata = null,
    };
}
