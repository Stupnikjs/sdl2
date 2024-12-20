// https://medium.com/@fwx5618177/zig-concurrency-implementation-methods-69bc31c14c56 multithreading

const std = @import("std");
const math = std.math;
const builtin = @import("builtin");
const endian = builtin.cpu.arch.endian();

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

fn sdlPanic() noreturn {
    const str = @as(?[*:0]const u8, SDL.SDL_GetError()) orelse "unknown error";
    @panic(std.mem.sliceTo(str, 0));
}

pub fn InitSpec(sr: c_int, format: SDL.SDL_AudioFormat, channels: u8, samples: u16) SDL.SDL_AudioSpec {
    // if format is 65534 or F32 =>
    // if format is 1 or U8
    return .{
        .freq = sr,
        .format = format,
        .channels = channels,
        // chunk size read by the callback
        .samples = samples,
        .userdata = null,
    };
}

// adapt to bits per samples 16 or 24
pub fn SDL_PlayBuffer(buf: [*c]u8, spec: SDL.SDL_AudioSpec, len: u32) !void {

    // Initialize SDL with audio
    if (SDL.SDL_Init(SDL.SDL_INIT_AUDIO) < 0) {
        std.debug.print("SDL_Init failed\n", .{});
        return;
    }
    var optained: SDL.SDL_AudioSpec = undefined;
    // Open the audio device
    const device_id = SDL.SDL_OpenAudioDevice(null, // Default device
        0, // Default frequency
        &spec, // Audio spec (from SDL_LoadWAV)
        &optained, // No need to pass desired spec, we use the loaded one
        SDL.SDL_AUDIO_ALLOW_ANY_CHANGE // Allow SDL to adjust settings
    );
    std.debug.print("{any} \n", .{optained});
    std.debug.print("{any} \n", .{spec});
    if (device_id == 0) {
        std.debug.print("SDL_OpenAudioDevice failed\n", .{});
        SDL.SDL_Quit();
        return;
    }

    // load wav here
    defer SDL.SDL_CloseAudioDevice(device_id);
    defer SDL.SDL_Quit(); // Quit SDL

    // Queue the audio buffer to the audio device

    const queue_result = SDL.SDL_QueueAudio(device_id, buf, len); // Example size: 2 bytes per sample (stereo 16-bit)
    if (queue_result != 0) {
        std.debug.print("SDL_QueueAudio failed\n", .{});
        const err = SDL.SDL_GetError();
        std.debug.print("{any}", .{err.*});
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
