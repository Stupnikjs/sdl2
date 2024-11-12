const std = @import("std");
const types = @import("types.zig");
const effect = @import("effect.zig");
const SoundParams = types.SoundParams;
const math = std.math;
const bufferToCSV = @import("csv.zig").bufferToCSV;
const tobytes = types.intToBytes;

pub const Instrument = enum {
    sinWave,
    squareWave,
    triangleWave,
};

pub fn playMap(buffer: []u8, offset: *f64, params: SoundParams, map: PlayMap, allocator: std.mem.Allocator) !void {
    const buffer_len_float: f64 = @floatFromInt(buffer.len);
    const chunk_size_usize: usize = @intCast(params.chunk_len);
    const chunk_size_f64: f64 = @floatFromInt(chunk_size_usize);
    const iter_num: f64 = buffer_len_float / chunk_size_f64;

    // last iteration to finsh buffer
    const rest: f64 = @mod(buffer_len_float, iter_num);

    // inter num rouned to int 
    const iter_num_usize: usize = @intFromFloat(iter_num);
    const rest_usize: usize = @intFromFloat(rest);

    // each loop allocate a chunk buffer 
    // and copy it to the main buffer passed to sdl 
    // last iteration is with the rest 
    // should be able to pass instrument for each chunk 
    // the play map should be same length as iteration if iter_num_usize != map.seq_len 
    // so we should iter on map 


    for (0..iter_num_usize + 1) |i| {
        if (i != iter_num_usize) {
            const buff = try InstrumentToBuff(instrument, chunk_size_usize, offset, params, allocator);
            @memcpy(buffer[i * chunk_size_usize .. i * chunk_size_usize + chunk_size_usize], buff);
            allocator.free(buff);
        } else {
            const buff = try InstrumentToBuff(Instrument.sinWave, rest_usize, offset, params, allocator);
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

    for (0..buffer_len / 2) |i| {

        // get the value and increment the offset
        const val: f64 = switch (instrument) {
            Instrument.sinWave => sinFunc(sin_offset, params.frequency, sr_f64),
            Instrument.squareWave => squareFunc(sin_offset, params.frequency, sr_f64),
            else => return error.invalidLength,
        };
        const int16: i16 = @intFromFloat(val * params.amplitude);
        const bytes = tobytes(i16, int16);

        buff[i * 2] = bytes[0];
        buff[i * 2 + 1] = bytes[1];
    }
    return buff;
}

pub fn sinFunc(offset: *f64, note: f64, sr_f64: f64) f64 {
    const phase_increment: f64 = 2 * math.pi * note / sr_f64;
    const sin_val = @sin(offset.*);
    offset.* += phase_increment;
    return sin_val;
}

// the tone aint right
pub fn squareFunc(offset: *f64, note: f64, sr_f64: f64) f64 {
    const phase_increment: f64 = 2 * math.pi * note / sr_f64;
    const sin_val: f64 = if (@sin(offset.*) > 0) 1 else -1;
    offset.* += phase_increment;
    return sin_val;
}

// pub fn triangleFunc(offset: *f64, note: f64, sr_f64: f64) f64 {}
