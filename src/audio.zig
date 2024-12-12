const std = @import("std");
const types = @import("types.zig");
const SoundParams = types.SoundParams;
const math = std.math;
const bufferError = types.bufferError;
const tobytes = types.intToBytes;
const Instrument = types.Instrument;
const Note = types.Note;

pub fn chunk_by_chunk_len(buffer: []u8, params: SoundParams) !void {
    const allocator = params.allocator;
    const offset1: *f64 = try allocator.create(f64);
    const offset0: *f64 = try allocator.create(f64);
    offset1.* = 0;
    offset0.* = 300;
    defer allocator.destroy(offset1);
    defer allocator.destroy(offset0);
    const offsetBoxes = try allocator.alloc(*f64, 2);
    offsetBoxes[0] = offset0;
    offsetBoxes[1] = offset1;
    const iter_num_usize = buffer.len / params.chunk_len;
    const chunk_size: usize = @intCast(params.chunk_len);
    // need one more iteration for the rest of the chunk
    const mod = @mod(buffer.len, chunk_size);

    for (0..iter_num_usize) |i| {
        if (i != iter_num_usize) {
            const buff = try soundToBuffer(params.chunk_len, offsetBoxes, params);
            @memcpy(buffer[i * chunk_size .. i * chunk_size + chunk_size], buff);
            allocator.free(buff);
        }
    }
    const buff = try soundToBuffer(mod, offsetBoxes, params);
    @memcpy(buffer[iter_num_usize * chunk_size .. iter_num_usize * chunk_size + mod], buff);
}

pub fn soundToBuffer(buffer_len: usize, offsetBoxes: []*f64, params: SoundParams) ![]u8 {
    const allocator = params.allocator;
    const buff = try allocator.alloc(u8, buffer_len);
    const sr_f64: f64 = @floatFromInt(params.sr);
    for (0..buffer_len / 2) |i| {
        const i_f64: f64 = @floatFromInt(i);
        const val: f64 = calcWave(params.frequency, params.instrument, offsetBoxes[0], sr_f64, if (true) i_f64 / 2000 else 0);
        const int16: i16 = @intFromFloat((val + 0) * params.amplitude);
        const bytes = tobytes(i16, int16);
        buff[i * 2] = bytes[0];
        buff[i * 2 + 1] = bytes[1];
    }
    return buff;
}

fn calcWave(freq: f64, instrument: Instrument, sin_offset: *f64, sr_f64: f64, shift: f64) f64 {
    return switch (instrument) {
        Instrument.sinWave => sinFunc(sin_offset, freq, sr_f64, shift),
        Instrument.squareWave => squareFunc(sin_offset, freq, sr_f64, shift),
        Instrument.triangleWave => triangleFunc(sin_offset, freq, sr_f64, shift),
        Instrument.silence => silenceFunc(sin_offset, freq, sr_f64, shift),
        Instrument.kick => sinFunc(sin_offset, freq, sr_f64, shift), // change this 
    };
}

// MATH FUNCTIONS TO BUILD THE WAVE

pub fn sinFunc(offset: *f64, note: f64, sr_f64: f64, shift: f64) f64 {
    const phase_increment: f64 = 2 * math.pi * note / sr_f64;
    const sin_val = @sin(offset.* + shift);
    offset.* += phase_increment;
    return sin_val;
}

pub fn squareFunc(offset: *f64, note: f64, sr_f64: f64, shift: f64) f64 {
    const phase_increment: f64 = 2 * math.pi * note / sr_f64;
    const sin_val: f64 = if (@sin(offset.* + shift) > 0) 1 else -1;
    offset.* += phase_increment;
    return sin_val;
}

pub fn silenceFunc(offset: *f64, note: f64, sr_f64: f64, shift: f64) f64 {
    _ = offset;
    _ = shift;
    _ = note;
    _ = sr_f64;
    return 0;
}

pub fn triangleFunc(offset: *f64, note: f64, sr_f64: f64, shift: f64) f64 {
    const phase_increment: f64 = note / sr_f64;

    // Update the phase and wrap between 0.0 and 1.0
    offset.* = (@mod(offset.* + phase_increment + shift, 1.0));

    const phase = 2.0 * offset.* - 1.0;
    return if (phase < 0.0) -phase else phase;
}
