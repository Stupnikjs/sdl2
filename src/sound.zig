// sound effect
const std = @import("std");
const math = std.math;
const int = @import("int.zig");
const tobytes = int.intToBytes;
const bufferError = @import("types.zig").bufferError;
const bufferToCSV = @import("csv.zig").bufferToCSV;
const SoundParams = @import("types.zig").SoundParams;

// a slice is a pointer
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
            const buff = try sinToBuff(chunk_size_usize, sin_offset, params, allocator);
            @memcpy(buffer[i * chunk_size_usize .. i * chunk_size_usize + chunk_size_usize], buff);
            allocator.free(buff);
        } else {
            const buff = try sinToBuff(rest_usize, sin_offset, params, allocator);
            @memcpy(buffer[iter_num_usize * chunk_size_usize .. iter_num_usize * chunk_size_usize + rest_usize], buff);
            allocator.free(buff);
        }
    }
    try bufferToCSV(buffer);
    return;
}

// needs chunk len params
pub fn sinToBuff(buffer_len: usize, sin_offset: *f64, params: SoundParams, allocator: std.mem.Allocator) ![]u8 {
    const buff = try allocator.alloc(u8, buffer_len);
    const sr_f64: f64 = @floatFromInt(params.sr);
    const note: f64 = @floatFromInt(params.frequency);

    // for each sample the arg of the sin is incremented
    const phase_increment: f64 = 2 * math.pi * note / sr_f64;

    const fade_length: f64 = @floatFromInt(buffer_len / 5);
    for (0..buffer_len / 2) |i| {
        var fade_factor: f64 = 1.0;
        const float_i: f64 = @floatFromInt(i);
        if (i < fade_length) {
            // Fade-in (first fade_length samples)
            fade_factor = float_i / fade_length;
        } else if (i >= (buffer_len / 2) - fade_length) {
            // Fade-out (last fade_length samples)
            // fade_factor = @floatFromInt((buffer_len / 2) - i) / @floatFromInt(fade_length);
        }
        // float conversion

        const sin_val: f64 = @sin(sin_offset.*) * fade_factor;
        const int16: i16 = @intFromFloat(sin_val * params.amplitude);

        const bytes = tobytes(i16, int16);

        buff[i * 2] = if (i < buffer_len / 5) 1 else bytes[0];
        buff[i * 2 + 1] = if (i < buffer_len / 5) 1 else bytes[1];

        sin_offset.* += phase_increment;

        if (sin_offset.* >= 2.0 * math.pi) {
            sin_offset.* -= 2.0 * math.pi;
        }
    }
    return buff;
}
