const std = @import("std");
const endian = @import("builtin").cpu.arch.endian();
const math = std.math;
const tobytes = @import("types.zig").intToBytes;
const playInstrument = @import("instrument.zig").playInstrument;
const Instrument = @import("instrument.zig").Instrument;
const SoundParams = types.SoundParams;
const effect = @import("effect.zig");
const types = @import("types.zig");
const bufferError = types.bufferError;
const SDL = @cImport({
    @cInclude("SDL2/SDL.h");
});

const maxU16: usize = @as(usize, math.maxInt(u16));

pub var audio_pos: ?[*]u8 = null; // Pointer to the audio buffer.
pub var audio_len: usize = 0; // Remaining length of the sample to play.
pub const sample_byte_num: usize = 1;
pub var sec_len: f64 = 10;

fn my_audio_callback(ctx: ?*anyopaque, stream: [*c]u8, len: c_int) callconv(.C) void {
    _ = ctx;

    // Accessing global variables audio_pos and audio_len
    // Crunching might come from here

    const len_usize: usize = @intCast(len);
    const audio_len_usize: usize = @intCast(audio_len);
    const length = if (len > audio_len) audio_len_usize else len_usize;

    const audio_cast: [*c]u8 = @ptrCast(audio_pos);

    const limit: f64 = 4000 * sec_len;
    const limit_usize: usize = @intFromFloat(limit);
    if (audio_len < limit_usize) {
        _ = SDL.SDL_memset(stream, 0, length); // Copy audio data to stream
        audio_len = 0;
        return;
    }
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
    return .{
        .freq = sr_c,
        .format = SDL.AUDIO_S16,
        .channels = 1,
        .samples = samples,
        .callback = my_audio_callback,
        .userdata = null,
    };
}

pub fn PlayAudio(params: SoundParams) !void {
    if (SDL.SDL_Init(SDL.SDL_INIT_VIDEO | SDL.SDL_INIT_EVENTS | SDL.SDL_INIT_AUDIO) < 0) sdlPanic();
    defer SDL.SDL_Quit();
    var audio_len_float: f64 = @floatFromInt(params.sr * sample_byte_num);
    audio_len_float *= sec_len;
    audio_len = @intFromFloat(audio_len_float);
    const allocator = std.heap.page_allocator;
    var audioSpec = InitSpec(params.sr, 1024);
    const buffer = try allocator.alloc(u8, audio_len);
    audio_pos = buffer.ptr;

    const sin_offset: *f64 = try allocator.create(f64);
    sin_offset.* = 0;
    defer allocator.destroy(sin_offset);

    const map:PlayMap = PlayMap.init(); 

    try playMap(buffer, sin_offset, params, map, allocator);

    _ = SDL.SDL_OpenAudio(&audioSpec, null);

    SDL.SDL_PauseAudio(0);

    while (audio_len > 1000) {
        SDL.SDL_Delay(1000);
    }

    if (audio_len == 0) {
        SDL.SDL_CloseAudio();
        allocator.free(buffer);
        _ = SDL.SDL_Quit();
    }
}
// a slice is a pointer
// buffer to big
