const std = @import("std");
const builtin = @import("builtin");
const tobytes = @import("types.zig").intToBytes;
// fade

// bitreverse
pub fn fade(buffer: []u8, fadeLength: f64) !void {
    for (0..buffer.len / 2) |i| {
        const i_float: f64 = @floatFromInt(i);
        var intBuff: [2]u8 = [2]u8{ buffer[i * 2], buffer[i * 2 + 1] };
        var int16: i16 = undefined;
        _ = std.mem.writeInt(i16, &intBuff, int16, builtin.cpu.arch.endian());
        var float_int16: f64 = @floatFromInt(int16);
        const buff_len_float: f64 = @floatFromInt(buffer.len);
        const minus_ratio: usize = @intFromFloat(fadeLength * buff_len_float / 2);
        const fadeFactor: f64 = 1 / ((100 - i_float));
        if (i < minus_ratio) {
            float_int16 *= fadeFactor;
        }
        int16 = @intFromFloat(float_int16);
        const int16Bytes = tobytes(i16, int16);
        buffer[i * 2] = int16Bytes[0];
        buffer[i * 2 + 1] = int16Bytes[1];
    }
}
