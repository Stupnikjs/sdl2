const std = @import("std");
const builtin = @import("builtin");
const tobytes = @import("types.zig").intToBytes;
// fade

// bitreverse
pub fn fade(buffer: []u8) !void {
    for (0..buffer.len / 2) |i| {

        // conversion to float
        // const i_float: f64 = @floatFromInt(i);
        var initialI16Bytes: [2]u8 = [2]u8{ buffer[i * 2], buffer[i * 2 + 1] };
        var int16: i16 = undefined;
        _ = std.mem.writeInt(i16, &initialI16Bytes, int16, builtin.cpu.arch.endian());
        var float_Int16: f64 = @floatFromInt(int16);
        const buff_len_float: f64 = @floatFromInt(buffer.len);

        // logic of fade
        const minus_ratio: usize = @intFromFloat(0.2 * buff_len_float / 2);

        if (i > buff_len_float * (1 - minus_ratio)) {
            const factor: f64 = 1 / (20 * i);
            float_Int16 *= factor;
        }

        // convert back to i16
        int16 = @intFromFloat(float_Int16);
        const int16Bytes = tobytes(i16, int16);
        buffer[i * 2] = int16Bytes[0];
        buffer[i * 2 + 1] = int16Bytes[1];
    }
}
