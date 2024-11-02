// sound effect
const std = @import("std");
const math = std.math;
const int = @import("int.zig");
const tobytes = int.intToBytes;
const bufferError = @import("types.zig").bufferError;
const bufferToCSV = @import("csv.zig").bufferToCSV;

// a slice is a pointer
pub fn sinCreator(buffer: []u8, sr: u32, frequency: f64) !void {
    const amplitude: f64 = 32767.0;
    if (buffer.len % 2 != 0) return bufferError.invalidLength;
    for (0..buffer.len / 2) |i| {
        const sr_f64: f64 = @floatFromInt(sr);
        const if64: f64 = @floatFromInt(i);
        //
        const u_u16: u16 = @truncate(i);
        const i_i16: i16 = @intCast(u_u16);

        const time = if64 / sr_f64;
        const sin_val: f64 = @trunc(@sin(2 * math.pi * time * frequency) * amplitude);
        var int16: i16 = @intFromFloat(sin_val);
        if (i < 400) int16 = @divTrunc(int16, (400 - i_i16));
        const bytes = tobytes(i16, int16);
        buffer[i * 2] = bytes[0];
        buffer[i * 2 + 1] = bytes[1];
    }
    try bufferToCSV(buffer);
    return;
}
