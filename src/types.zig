const std = @import("std");
const builtin = @import("builtin");
const Effect = @import("effect.zig").Effect;
const math = std.math;
const tobytes = @import("types.zig").intToBytes;
const api = @import("sdl.zig");
const types = @import("types.zig");
const pow = math.pow;

pub const bufferError = error{
    invalidLength,
};

pub const Instrument = enum {
    sinWave,
    squareWave,
    triangleWave,
    silence,
};

pub fn intToBytes(T: type, source: T) []u8 {
    var buff: [@divExact(@typeInfo(T).int.bits, 8)]u8 = undefined;
    _ = std.mem.writeInt(T, &buff, source, builtin.cpu.arch.endian());
    return &buff;
}

pub const SoundParams = struct {
    sr: usize,
    chunk_len: u16,
    amplitude: f64,
    allocator: std.mem.Allocator,
    pub fn init(sr: usize, chunk_len: u16, allocator: std.mem.Allocator) SoundParams {
        return .{
            .sr = sr,
            .chunk_len = chunk_len,
            .amplitude = 10000,
            .allocator = allocator,
        };
    }
};

pub const Track = struct {
    effect: Effect, // change it to array of effect
    seq: []const Note,

    pub fn init(effect: Effect, seq: []const Note) Track {
        return .{
            .effect = effect,
            .seq = seq,
        };
    }
};

pub const Note = struct {
    instrument: Instrument,
    note: f64,

    pub fn init(in: Instrument, note: f64) Note {
        return .{
            .instrument = in,
            .note = note,
        };
    }
};

pub const NoteLetter = enum {
    A,
    B, // Half tone
    C,
    D, // Half tone
    E,
    F,
    G,
};

pub fn getNoteFactor(note: f64, tone_num: f64) f64 {
    return note * pow(f64, 2, (tone_num / 12));
}

pub fn playFull(main: f64) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const params = types.SoundParams.init(
        44100,
        getNoteFactor(main, 6),
        1024,
        gpa.allocator(),
    );

    try api.PlayAudio(params);
}
