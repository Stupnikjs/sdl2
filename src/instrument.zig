const std = @import("std");
const types = @import("types.zig");
const effect = @import("effect.zig");
const SoundParams = types.SoundParams;
const math = std.math;
const bufferToCSV = @import("csv.zig").bufferToCSV;
const tobytes = types.intToBytes;
// sin wave
// square wave
// triangle wave
// instruments put sound on some pos (seq)

// iterate over buffer and only write on
// buffers pos
pub const Instrument = enum {
    sinWave,
    squareWave,
    triangleWave,
};

pub fn playInstrument(buffer: []u8, params: SoundParams, allocator: std.mem.Allocator) !void {
    const buffer_len_float: f64 = @floatFromInt(buffer.len);
    const chunk_size_usize: usize = @intCast(params.chunk_len);
    const chunk_size_f64: f64 = @floatFromInt(chunk_size_usize);
    const iter_num: f64 = buffer_len_float / chunk_size_f64;
    const rest: f64 = @mod(buffer_len_float, iter_num);
    const iter_num_usize: usize = @intFromFloat(iter_num);
    const rest_usize: usize = @intFromFloat(rest);
    const sin_offset: *f64 = try allocator.create(f64);
    sin_offset.* = 0;
    defer allocator.destroy(sin_offset);
    for (0..iter_num_usize + 1) |i| {
        if (i != iter_num_usize) {
            const buff = try InstrumentToBuff(Instrument.sinWave, chunk_size_usize, sin_offset, params, allocator);
            try effect.fade(buff, 0.1);
            @memcpy(buffer[i * chunk_size_usize .. i * chunk_size_usize + chunk_size_usize], buff);
            allocator.free(buff);
        } else {
            const buff = try InstrumentToBuff(Instrument.sinWave, rest_usize, sin_offset, params, allocator);
            try effect.fade(buff, 0.1);
            @memcpy(buffer[iter_num_usize * chunk_size_usize .. iter_num_usize * chunk_size_usize + rest_usize], buff);
            allocator.free(buff);
        }
    }
    try bufferToCSV(buffer);
    return;
}

pub fn InstrumentToBuff(instrument: Instrument, buffer_len: usize, sin_offset: *f64, params: SoundParams, allocator: std.mem.Allocator) ![]u8 {
    const buff = try allocator.alloc(u8, buffer_len);
    const sr_f64: f64 = @floatFromInt(params.sr);
    const note: f64 = @floatFromInt(params.frequency);

    // GET THE DIRECTION OF THE WAVE FOR JOIN

    for (0..buffer_len / 2) |i| {
        if (instrument != Instrument.sinWave) @panic("not working");
        const sin_val: f64 = sinFunc(sin_offset, note, sr_f64);
        const int16: i16 = @intFromFloat(sin_val * params.amplitude);
        const bytes = tobytes(i16, int16);

        buff[i * 2] = bytes[0];
        buff[i * 2 + 1] = bytes[1];
    }
    return buff;
}

pub fn sinFunc(offset: *f64, note: f64, sr_f64: f64) f64 {
    const phase_increment: f64 = 2 * math.pi * note / sr_f64;
    const sin_val = @sin(offset.*);
    offset.* -= phase_increment;
    return sin_val;
}
