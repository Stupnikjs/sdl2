// https://medium.com/@fwx5618177/zig-concurrency-implementation-methods-69bc31c14c56 multithreading

const std = @import("std");
const math = std.math;
const builtin = @import("builtin");
const endian = builtin.cpu.arch.endian();

const sound = @import("sound.zig");
const Instrument = sound.Instrument;

pub const SoundParams = struct {
    sr: usize,
    amplitude: f64,
    frequency: f64,
    chunk_len: u16,
    allocator: std.mem.Allocator,
    pub fn default() SoundParams {
        return .{
            .sr = 44100,
            .amplitude = 4000,
            .frequency = 440,
            .chunk_len = 256, // lower it is cleaner the sound is
            .allocator = std.heap.page_allocator,
        };
    }
};

pub fn intToBytes(T: type, source: T) []u8 {
    var buff: [@divExact(@typeInfo(T).int.bits, 8)]u8 = undefined;
    _ = std.mem.writeInt(T, &buff, source, builtin.cpu.arch.endian());
    return &buff;
}

pub const SDL = @cImport({
    @cInclude("SDL2/SDL.h");
});

pub var audio_pos: ?[*]u8 = null; // Pointer to the audio buffer.
pub var audio_len: usize = fixed_len; // Remaining length of the sample to play.
pub const fixed_len: c_int = 2048 * 40;

fn my_audio_callback(ctx: ?*anyopaque, stream: [*c]u8, len: c_int) callconv(.C) void {
    _ = ctx;
    const len_usize: usize = @intCast(len);
    const audio_cast: [*c]u8 = @ptrCast(audio_pos);
    const remaining = len_usize;
    std.debug.print("audio len {d} remaining {d} \n", .{ audio_len, remaining });
    const length_to_copy = if (remaining > audio_len) audio_len else remaining;
    if (audio_len > 0) {
        _ = SDL.SDL_memcpy(stream, audio_cast, length_to_copy);
    } else {
        _ = SDL.SDL_memset(stream, 0, length_to_copy);
    }
    audio_pos.? += length_to_copy;
    audio_len -= length_to_copy;
}

fn my_audio_callback_loop(ctx: ?*anyopaque, stream: [*c]u8, len: c_int) callconv(.C) void {
    _ = ctx;
    // len is the bytes num of the chunk passed into the stream
    const len_usize: usize = @intCast(len);
    const audio_cast: [*c]u8 = @ptrCast(audio_pos);

    if (audio_len >= len_usize) {
        _ = SDL.SDL_memcpy(stream, audio_cast, len_usize);
        audio_pos.? += len_usize;
        audio_len -= len_usize;
    } else {
        _ = SDL.SDL_memcpy(stream, audio_cast, audio_len);
        audio_pos.? -= fixed_len + audio_len;
        audio_len = fixed_len;
    }
}

fn sdlPanic() noreturn {
    const str = @as(?[*:0]const u8, SDL.SDL_GetError()) orelse "unknown error";
    @panic(std.mem.sliceTo(str, 0));
}

pub fn DefaultSpec(loop: bool) SDL.SDL_AudioSpec {
    const sr_c: c_int = 44100;
    return .{
        .freq = sr_c,
        .format = SDL.AUDIO_U16,
        .channels = 1,
        // chunk size read by the callback
        .samples = 2048,
        .callback = if (loop) my_audio_callback_loop else my_audio_callback,
        .userdata = null,
    };
}

pub fn buildBuffer() ![]u8 {
    const defautParams = SoundParams.default();
    const buffer: []u8 = try defautParams.allocator.alloc(u8, fixed_len);
    try chunkingAndSound(buffer, defautParams);
    return buffer;
}

// adapt to bits per samples 16 or 24
pub fn SDL_PlayBuffer(buffer: [*]u8, loop: bool) !void {
    if (SDL.SDL_Init(SDL.SDL_INIT_VIDEO | SDL.SDL_INIT_EVENTS | SDL.SDL_INIT_AUDIO) < 0) sdlPanic();
    audio_len = fixed_len;
    var audioSpec = DefaultSpec(loop);

    audio_pos = buffer;

    _ = SDL.SDL_OpenAudio(&audioSpec, null);
    SDL.SDL_PauseAudio(0);

    while (audio_len > 1000) {
        SDL.SDL_Delay(1000);
    }

    // if (audio_len == 0) SDL.SDL_AudioQuit(); // comment for infinite loop
}

pub fn chunkingAndSound(buffer: []u8, params: SoundParams) !void {
    const allocator = params.allocator;
    const offset: *f64 = try allocator.create(f64);
    offset.* = 0;
    defer allocator.destroy(offset);
    const iter_num_usize = buffer.len / params.chunk_len;
    const chunk_size: usize = @intCast(params.chunk_len);

    const mod = @mod(buffer.len, chunk_size); //   like the rest

    for (0..iter_num_usize) |i| {
        if (i != iter_num_usize) {
            const buff = try soundToBufferI24(params.chunk_len, offset, params);
            @memcpy(buffer[i * chunk_size .. i * chunk_size + chunk_size], buff);
            allocator.free(buff);
        }
    }
    const buff = try soundToBufferI24(mod, offset, params);
    @memcpy(buffer[iter_num_usize * chunk_size .. iter_num_usize * chunk_size + mod], buff);
}

pub fn soundToBufferI16(buffer_len: usize, offset: *f64, params: SoundParams) ![]u8 {
    const allocator = params.allocator;
    const buff = try allocator.alloc(u8, buffer_len);
    const sr_f64: f64 = @floatFromInt(params.sr);
    for (0..buffer_len / 2) |i| {
        const i_f64: f64 = @floatFromInt(i);
        const val: f64 = sound.calcWave(params.frequency, Instrument.sinWave, offset, sr_f64, if (true) i_f64 / 2000 else 0);
        const int16: i16 = @intFromFloat((val + 0) * params.amplitude);
        const bytes = intToBytes(i16, int16);
        buff[i * 2] = bytes[0];
        buff[i * 2 + 1] = bytes[1];
    }
    return buff;
}

pub fn soundToBufferI24(buffer_len: usize, offset: *f64, params: SoundParams) ![]u8 {
    if (@mod(buffer_len, 3) != 0) return error.InvalidBufferLen;
    const allocator = params.allocator;
    const buff = try allocator.alloc(u8, buffer_len);
    const sr_f64: f64 = @floatFromInt(params.sr);
    for (0..buffer_len / 3) |i| {
        const i_f64: f64 = @floatFromInt(i);
        const val: f64 = sound.calcWave(params.frequency, Instrument.sinWave, offset, sr_f64, if (true) i_f64 / 2000 else 0);
        const int24: i24 = @intFromFloat((val + 0) * params.amplitude);
        const bytes = intToBytes(i24, int24);
        buff[i * 3] = bytes[0];
        buff[i * 3 + 1] = bytes[1];
        buff[i * 3 + 2] = bytes[2];
    }
    return buff;
}
