const std = @import("std");
const builtin = @import("builtin");
const pow = std.math.pow;
const Instrument = @import("instrument.zig").Instrument;
const Effect = @import("effect.zig").Effect;

pub const bufferError = error{
    invalidLength,
};

pub fn intToBytes(T: type, source: T) []u8 {
    var buff: [@divExact(@typeInfo(T).int.bits, 8)]u8 = undefined;
    _ = std.mem.writeInt(T, &buff, source, builtin.cpu.arch.endian());
    return &buff;
}

pub const SoundParams = struct {
    sr: usize,
    frequency: f64,
    chunk_len: u16,
    amplitude: f64,
    allocator: std.mem.Allocator,
    pub fn init(sr: usize, frequency: f64, chunk_len: u16, allocator: std.mem.Allocator) SoundParams {
        return .{
            .sr = sr,
            .frequency = frequency,
            .chunk_len = chunk_len,
            .amplitude = 10000,
            .allocator = allocator,
        };
    }
};

pub const Track = struct {
    effect: Effect, // change it to array of effect
    seq: []const Instrument,

    pub fn init(effect: Effect, seq: []const Instrument) Track {
        return .{
            .effect = effect,
            .seq = seq,
        };
    }
};
