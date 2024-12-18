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

pub fn my_audio_callback(ctx: ?*anyopaque, stream: [*c]u8, len: c_int) callconv(.C) void {
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

pub fn my_audio_callback_loop(ctx: ?*anyopaque, stream: [*c]u8, len: c_int) callconv(.C) void {
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

pub fn InitSpec(sr: c_int, format: SDL.SDL_AudioFormat, channels: u8, samples: u16, loop: bool) SDL.SDL_AudioSpec {
    // if format is 65534 or F32 =>
    // if format is 1 or U8
    return .{
        .freq = sr,
        .format = format,
        .channels = channels,
        // chunk size read by the callback
        .samples = samples,
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
pub fn SDL_PlayBuffer() !void {
    // Initialize SDL with audio
    if (SDL.SDL_Init(SDL.SDL_INIT_AUDIO) < 0) {
        std.debug.print("SDL_Init failed\n", .{});
        return;
    }
    var spec_loaded: SDL.SDL_AudioSpec = undefined;
    var audio_buf: [*c]u8 = undefined;
    var audio_len_un: u32 = undefined;
    const spe = SDL.SDL_LoadWAV("./samples/test.wav", &spec_loaded, &audio_buf, &audio_len_un);
    spe.*.callback = my_audio_callback;
    // Open the audio device
    const device_id = SDL.SDL_OpenAudioDevice(null, // Default device
        0, // Default frequency
        spe, // Audio spec (from SDL_LoadWAV)
        null, // No need to pass desired spec, we use the loaded one
        SDL.SDL_AUDIO_ALLOW_ANY_CHANGE // Allow SDL to adjust settings
    );
    std.debug.print("{d}", .{audio_buf[0..44]});
    if (device_id == 0) {
        std.debug.print("SDL_OpenAudioDevice failed\n", .{});
        SDL.SDL_Quit();
        return;
    }
    defer SDL.SDL_CloseAudioDevice(device_id);
    defer SDL.SDL_Quit(); // Quit SDL

    // Queue the audio buffer to the audio device

    const queue_result = SDL.SDL_QueueAudio(device_id, audio_buf, audio_len_un); // Example size: 2 bytes per sample (stereo 16-bit)
    if (queue_result != 0) {
        std.debug.print("SDL_QueueAudio failed\n", .{});
        SDL.SDL_CloseAudioDevice(device_id);
        SDL.SDL_Quit();
        return;
    }

    // Start playing the audio (unpause the device)
    SDL.SDL_PauseAudioDevice(device_id, 0); // 0 to unpause (start playing)

    // Wait until audio finishes playing
    var bytes_left = SDL.SDL_GetQueuedAudioSize(device_id);
    while (bytes_left > 0) {
        std.time.sleep(1000000);
        bytes_left = SDL.SDL_GetQueuedAudioSize(device_id); // Check remaining audio to play
    }

    // Clean up and close audio device

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
            const buff = try soundToBufferI16(params.chunk_len, offset, params);
            @memcpy(buffer[i * chunk_size .. i * chunk_size + chunk_size], buff);
            allocator.free(buff);
        }
    }
    const buff = try soundToBufferI16(mod, offset, params);
    @memcpy(buffer[iter_num_usize * chunk_size .. iter_num_usize * chunk_size + mod], buff);
}

pub fn soundToBufferI16(buffer_len: usize, offset: *f64, params: SoundParams) ![]u8 {
    const allocator = params.allocator;
    const buff = try allocator.alloc(u8, buffer_len);
    const sr_f64: f64 = @floatFromInt(params.sr);
    for (0..buffer_len / 2) |i| {
        const i_f64: f64 = @floatFromInt(i);
        const val: f64 = sound.calcWave(params.frequency, Instrument.triangleWave, offset, sr_f64, if (true) i_f64 / 2000 else 0);
        const int16: i16 = @intFromFloat((val + 0) * params.amplitude);
        const bytes = intToBytes(i16, int16);
        buff[i * 2] = bytes[0];
        buff[i * 2 + 1] = bytes[1];
    }
    return buff;
}

pub fn silenceToBuffer(buffer_len: usize, offset: *f64, params: SoundParams) ![]u8 {
    _ = offset;
    const allocator = params.allocator;
    const buff = try allocator.alloc(u8, buffer_len);
    for (0..buffer_len) |i| {
        buff[i] = 0;
    }
    return buff;
}
