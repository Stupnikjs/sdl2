// sound effect
const std = @import("std");
const math = std.math;
const int = @import("int.zig");
const tobytes = int.intToBytes;
const bufferError = @import("types.zig").bufferError;
const bufferToCSV = @import("csv.zig").bufferToCSV;

pub const chunk_size: comptime_float = 8192;

// a slice is a pointer
pub fn sinCreator(buffer: []u8, sr: u32, frequency: f64, allocator: std.mem.Allocator) !void {
    const amplitude: f64 = 32767.0;
    const buffer_len_float: f64 = @floatFromInt(buffer.len);
    const iter_num: f64 = buffer_len_float / chunk_size;
    const rest: f64 = buffer_len_float % iter_num;

    for (0..iter_num + 1) |i| {
        if (i != iter_num) {
            const buff = try allocator.alloc(u8, chunk_size);
        } else {
            const buff = try allocator.alloc(u8, rest);
        }
        const sr_f64: f64 = @floatFromInt(sr);
        const if64: f64 = @floatFromInt(i);
        const time = if64 / sr_f64;
        const sin_val: f64 = @trunc(@sin(2 * math.pi * time * frequency) * amplitude);
        const int16: i16 = @intFromFloat(sin_val);
        const bytes = tobytes(i16, int16);
        buffer[i * 2] = bytes[0];
        buffer[i * 2 + 1] = bytes[1];
    }
    try bufferToCSV(buffer);
    return;
}

pub fn sinToBuff(buff: []u8) !void {}
