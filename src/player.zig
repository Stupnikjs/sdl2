const std = @import("std");
const types = @import("types.zig");
const SoundParams = types.SoundParams;
const math = std.math;
const bufferError = types.bufferError;
const tobytes = types.intToBytes;
const Instrument = types.Instrument;

// try implement an array of buffers
// array of offsets to duplicate sin wave 
pub fn play(buffer: []u8, offset: *f64, params: SoundParams, seq: []types.Note) !void {
    if (@mod(buffer.len, seq.len) != 0) return types.bufferError.invalidLength;
    const buffer_chunk_num: usize = seq.len;
    for (0..buffer_chunk_num) |i| {
        const sliced_buff = buffer[i * buffer.len / buffer_chunk_num .. (i + 1) * buffer.len / buffer_chunk_num];
        try innerLoop(sliced_buff, seq[i], offset, params);
    }

    // try bufferToCSV(buffer);
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

        // test two values 
        const val: f64 = switch (note.instrument) {
            Instrument.sinWave => sinFunc(sin_offset, note.note, sr_f64),
            Instrument.squareWave => squareFunc(sin_offset, note.note, sr_f64),
            Instrument.triangleWave => triangleFunc(sin_offset, note.note, sr_f64),
            Instrument.silence => silenceFunc(sin_offset, note.note, sr_f64),
        };

        // val2
        // int16 + val2_i16
        // use another offset 

        const int16: i16 = @intFromFloat(val * params.amplitude);
        const bytes = tobytes(i16, int16);

        buff[i * 2] = bytes[0];
        buff[i * 2 + 1] = bytes[1];
    }
    return buff;
}

// pass the number of notes ? or number of wave
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

pub fn triangleFunc(offset: *f64, note: f64, sr_f64: f64) f64 {
    const phase_increment: f64 = note / sr_f64;

    // Update the phase and wrap between 0.0 and 1.0
    offset.* = (@mod(offset.* + phase_increment, 1.0));

    const phase = 2.0 * offset.* - 1.0;
    return if (phase < 0.0) -phase else phase;
}

// Convert to CSV

pub fn bufferToCSV(buffer: []u8) !void {
    if (buffer.len % 2 != 0) return bufferError.invalidLength;
    const file = try std.fs.cwd().createFile("buf.csv", .{});

    for (0..buffer.len / 2) |i| {
        const first = buffer[i * 2];
        const sec = buffer[i * 2 + 1];
        const buff: [2]u8 = [2]u8{ first, sec };
        const sample: i16 = std.mem.bytesToValue(i16, &buff);
        var intStr: [6]u8 = undefined;
        _ = try std.fmt.bufPrint(&intStr, "{}", .{sample});
        _ = try file.write(&intStr);
        const space: [1]u8 = [1]u8{'\n'};
        _ = try file.write(&space);
    }

    file.close();
}
