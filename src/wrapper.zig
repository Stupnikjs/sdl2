const std = @import("std");
const endian = @import("builtin").cpu.arch.endian();
const math = std.math;
const tobytes = @import("int.zig").intToBytes;
const sinCreator = @import("sound.zig").sinCreator;
const types = @import("types.zig");
const bufferError = types.bufferError;

const SDL = @cImport({
    @cInclude("SDL2/SDL.h");
});

pub const chunk_size: comptime_int = 8192;
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

pub fn InitSpec(sr: usize, samples: u16) SDL.SDL_AudioSpec {
    const sr_c: c_int = @intCast(sr);
    // _ = samples;
    // _ = sr_c;
    return .{
        .freq = sr_c,
        .format = SDL.AUDIO_S16,
        .channels = 1,
        .samples = samples,
        .callback = my_audio_callback,
        .userdata = null,
    };
}

pub fn PlayAudio(sec: usize, frequency: usize, sr: usize) !void {
    // fixed samples

    if (SDL.SDL_Init(SDL.SDL_INIT_VIDEO | SDL.SDL_INIT_EVENTS | SDL.SDL_INIT_AUDIO) < 0)
        sdlPanic();
    defer SDL.SDL_Quit();

    audio_len = sr * sec;
    const rest: usize = audio_len % chunk_size;
    const rest_u16: u16 = @intCast(rest);
    const iter_num = @divFloor(audio_len, chunk_size);
    const allocator = std.heap.page_allocator;
    const buffers = try allocator.alloc(*[]u8, iter_num);

    for (0..iter_num) |i| {
        std.debug.print("{d}", .{i});
        const samples: u16 = if (i == iter_num - 1) rest_u16 else chunk_size;
        var audioSpec = InitSpec(sr, samples);
        const freq_usize: u32 = @intCast(audioSpec.freq);
        var buffer = try allocator.alloc(u8, chunk_size * 2);

        // this func should take start / end and frequency
        const frequency_f64: f64 = @floatFromInt(frequency);
        try sinCreator(buffer, freq_usize, frequency_f64);
        audio_pos = buffer.ptr;

        buffers[i] = &buffer;
        // joint all buffer before this call
        const num = SDL.SDL_OpenAudio(&audioSpec, null);

        if (num != 0) {
            const err = SDL.SDL_GetError();
            std.debug.print("SDL_Open audio failled {d} \n", .{err.*});
            std.debug.print("error occurs {d} \n", .{num});
            break;
        }
    }

    SDL.SDL_PauseAudio(0);
    while (audio_len > 100) {
        SDL.SDL_Delay(100);
    }
    SDL.SDL_CloseAudio();
    _ = SDL.SDL_Quit();

    defer {
        // Free each buffer in `buffers`
        for (buffers) |buf| {
            allocator.free(buf.*);
        }
        // Free the `buffers` array itself
        allocator.free(buffers);
    }
}

// a slice is a pointer
// buffer to big
