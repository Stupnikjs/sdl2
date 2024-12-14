const std = @import("std");
const builtin = @import("builtin");
const math = std.math;
const tobytes = @import("types.zig").intToBytes;
const api = @import("/sdl/sdl.zig");
const types = @import("types.zig");
const pow = math.pow;

pub const Instrument = enum {
    sinWave,
    squareWave,
    triangleWave,
    kick,
    silence,
};

// mooves to util
pub fn intToBytes(T: type, source: T) []u8 {
    var buff: [@divExact(@typeInfo(T).int.bits, 8)]u8 = undefined;
    _ = std.mem.writeInt(T, &buff, source, builtin.cpu.arch.endian());
    return &buff;
}

// to audio
pub const SoundParams = struct {
    sr: usize,
    chunk_len: u16,
    amplitude: f64,
    frequency: f64,
    instrument: Instrument,
    allocator: std.mem.Allocator,
    pub fn init(sr: usize, chunk_len: u16, amplitude: f64, frequency: f64, instrument: Instrument, allocator: std.mem.Allocator) SoundParams {
        return .{
            .sr = sr,
            .chunk_len = chunk_len,
            .amplitude = amplitude,
            .frequency = frequency,
            .instrument = instrument,
            .allocator = allocator,
        };
    }
    pub fn default() SoundParams {
        return .{
            .sr = 44100,
            .chunk_len = 1024,
            .amplitude = 4000,
            .frequency = 440,
            .instrument = Instrument.sinWave,
            .allocator = std.heap.page_allocator,
        };
    }
};
