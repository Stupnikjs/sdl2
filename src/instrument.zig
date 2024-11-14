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
    silence,
};

pub fn play(buffer: []u8, offset: *f64, params: SoundParams, tracks: []types.Track) !void {
    if (@mod(buffer.len, tracks[0].seq.len) != 0) return types.bufferError.invalidLength;

    const buffer_chunk_num: usize = tracks[0].seq.len;

    for (0..buffer_chunk_num) |i| {
        const sliced_buff = buffer[i * buffer.len / buffer_chunk_num .. (i + 1) * buffer.len / buffer_chunk_num];
        try innerLoop(sliced_buff, tracks[0].seq[i], offset, params);
    }

    try bufferToCSV(buffer);
    return;
}

pub fn innerLoop(buffer: []u8, note: types.Note, offset: *f64, params: SoundParams) !void {
    const allocator = params.allocator;
    const iter_num_usize = buffer.len / params.chunk_len;
    const chunk_size: usize = @intCast(params.chunk_len);
    // need one more iteration for the rest of the chunk
    const mod = @mod(buffer.len, chunk_size);

    for (0..iter_num_usize) |i| {
        if (i != iter_num_usize) {
            // pass the note also
            // need intrument and effect in some struct

            const buff = try InstrumentToBuff(note, params.chunk_len, offset, params);

            // copy intermediate buffer to main one
            @memcpy(buffer[i * chunk_size .. i * chunk_size + chunk_size], buff);
            allocator.free(buff);
        }
    }
    const buff = try InstrumentToBuff(note, mod, offset, params);
    @memcpy(buffer[iter_num_usize * chunk_size .. iter_num_usize * chunk_size + mod], buff);
}

pub fn InstrumentToBuff(note: types.Note, buffer_len: usize, sin_offset: *f64, params: SoundParams) ![]u8 {
    const allocator = params.allocator;
    const buff = try allocator.alloc(u8, buffer_len);
    const sr_f64: f64 = @floatFromInt(params.sr);

    for (0..buffer_len / 2) |i| {

        // get the value and increment the offset
        const val: f64 = switch (note.instrument) {
            Instrument.sinWave => sinFunc(sin_offset, note.note, sr_f64),
            Instrument.squareWave => squareFunc(sin_offset, note.note, sr_f64),
            Instrument.silence => silenceFunc(sin_offset, note.note, sr_f64),
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

pub fn silenceFunc(offset: *f64, note: f64, sr_f64: f64) f64 {
    _ = offset;
    _ = note;
    _ = sr_f64;
    return 0;
}

// pub fn triangleFunc(offset: *f64, note: f64, sr_f64: f64) f64 {}
