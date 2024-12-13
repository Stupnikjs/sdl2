// https://medium.com/@fwx5618177/zig-concurrency-implementation-methods-69bc31c14c56 multithreading

const std = @import("std");
const endian = @import("builtin").cpu.arch.endian();
const math = std.math;
const types = @import("../types.zig");
const tobytes = types.intToBytes;
const chunk_by_chunk_len = @import("../audio.zig").chunk_by_chunk_len;
const SoundParams = types.SoundParams;
const Note = types.Note;
const bufferError = types.bufferError;

pub const SDL = @cImport({
    @cInclude("SDL2/SDL.h");
});

const maxU16: usize = @as(usize, math.maxInt(u16));

pub var audio_pos: ?[*]u8 = null; // Pointer to the audio buffer.
pub var audio_len: usize = 0; // Remaining length of the sample to play.
pub const sample_byte_num: usize = 1;
pub var sec_len: f64 = 10;
pub const fixed_len: c_int = 2048 * 100 * 3;

// fn my_audio_callback_loop(ctx: ?*anyopaque, stream: [*c]u8, len: c_int) callconv(.C) void {
//     _ = ctx;
//     const len_usize: usize = @intCast(len);
//     const audio_cast: [*c]u8 = @ptrCast(audio_pos);
//     var remaining = len_usize;

//     const length_to_copy = if (remaining > audio_len) audio_len else remaining;

//     if (audio_len > 200) {
//         _ = SDL.SDL_memcpy(stream, audio_cast, length_to_copy);
//     } else {
//         _ = SDL.SDL_memset(stream, 0, length_to_copy);
//     }

//     if (audio_len == 0) {
//         std.debug.print("reinit \n", .{});
//         audio_pos.? -= fixed_len;
//         audio_len = fixed_len;
//     }
//     audio_pos.? += length_to_copy;
//     audio_len -= length_to_copy;
//     remaining -= length_to_copy;
// }

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
        // chunk size read by the callback
        .samples = samples,
        .callback = my_audio_callback,
        .userdata = null,
    };
}

pub fn buildBuffer(params: SoundParams) ![]u8 {
    var allocator = params.allocator;
    const buffer: []u8 = try allocator.alloc(u8, fixed_len);
    try chunk_by_chunk_len(buffer, params);
    return buffer;
}

// SDL call to a sound Buffer
// AT THE END OF EACH LOOP REINITIALIZE BUFFER
pub fn SDL_PlayBuffer(buffer: [*]u8, params: SoundParams) !void {
    if (SDL.SDL_Init(SDL.SDL_INIT_VIDEO | SDL.SDL_INIT_EVENTS | SDL.SDL_INIT_AUDIO) < 0) sdlPanic();
    audio_len = fixed_len;
    var audioSpec = InitSpec(params.sr, 1024);

    audio_pos = buffer;

    _ = SDL.SDL_OpenAudio(&audioSpec, null);
    SDL.SDL_PauseAudio(0);

    while (audio_len > 1000) {
        SDL.SDL_Delay(1000);
    }

    if (audio_len == 0) SDL.SDL_AudioQuit(); // comment for infinite loop
}

// TRY LOADING A SAMPLE REPEAT AND COMBINE IT WITH OTHER
pub fn SDL_PlayWav(filename: []const u8) !void {
    // SDL structures for WAV file handling
    var audioSpec: SDL.SDL_AudioSpec = undefined;
    var audio_buf: ?[*]u8 = null;
    var audi_len: u32 = 0;

    // Load WAV file
    _ = SDL.SDL_LoadWAV(filename.ptr, &audioSpec, &audio_buf, &audi_len);
}
