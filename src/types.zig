const std = @import("std");
const builtin = @import("builtin");
const pow = std.math.pow;

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
    pub fn init(sr: usize, frequency: f64, chunk_len: u16) SoundParams {
        return .{
            .sr = sr,
            .frequency = frequency,
            .chunk_len = chunk_len,
            .amplitude = 10000,
        };
    }
};



pub const PlayMap = struct {
    instruments: []Instrument,
    lens: []u8,
    notes: []f64,
    allocator: std.mem.Allocator, 
     
    pub fn 
}

pub const Step = struct {
    instrument: Instrument, 
    len: u8, 
    note:f64,
    


}
