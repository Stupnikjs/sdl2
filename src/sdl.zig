const std = @import("std");
const endian = @import("builtin").cpu.arch.endian();
const math = std.math;
const tobytes = @import("types.zig").intToBytes;
const playInstrument = @import("instrument.zig").playInstrument;
const SoundParams = types.SoundParams;
const MusicSeq = types.MusicSeq;
const types = @import("types.zig");
const bufferError = types.bufferError;
const SDL = @cImport({
    @cInclude("SDL2/SDL.h");
});

const maxU16: usize = @as(usize, math.maxInt(u16));

pub var audio_pos: ?[*]u8 = null; // Pointer to the audio buffer.
pub var audio_len: usize = 0; // Remaining length of the sample to play.
pub const sample_byte_num: usize = 2;

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

pub fn PlayAudio(sequence: MusicSeq, params: SoundParams) !void {
    if (SDL.SDL_Init(SDL.SDL_INIT_VIDEO | SDL.SDL_INIT_EVENTS | SDL.SDL_INIT_AUDIO) < 0) sdlPanic();
    defer SDL.SDL_Quit();

    audio_len = params.sr * sequence.seq.len;
    const allocator = std.heap.page_allocator;
    var audioSpec = InitSpec(params.sr, 4096);
    const buffer = try allocator.alloc(u8, audio_len * sample_byte_num);
    defer allocator.free(buffer);
    audio_pos = buffer.ptr;

    // sin_offset passed from each buffers
    const sin_offset: *f64 = try allocator.create(f64);
    sin_offset.* = 0;
    defer allocator.destroy(sin_offset);
    const temp_buff = try allocator.alloc(u8, params.sr * 2 );
    defer allocator.free(temp_buff);
    // need to create a buffer
    for (sequence.seq, 0..sequence.seq.len) |b, i| {
        if (b) try playInstrument(temp_buff, i, sin_offset, params, allocator);
        // temp_buff are not continuous to each other 
        @memcpy(buffer[i * params.sr * 2  .. (i + 1) * params.sr * 2 ], temp_buff);
    }

    _ = SDL.SDL_OpenAudio(&audioSpec, null);
    SDL.SDL_PauseAudio(0);

    while (audio_len > 100) {
        SDL.SDL_Delay(1000);
    }
    SDL.SDL_CloseAudio();
    _ = SDL.SDL_Quit();
}
// a slice is a pointer
// buffer to big
