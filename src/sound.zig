// sound effect
const std = @import("std");
const math = std.math;
const int = @import("int.zig");
const tobytes = int.intToBytes;
const bufferError = @import("types.zig").bufferError;
const bufferToCSV = @import("csv.zig").bufferToCSV;

pub const chunk_size: comptime_float = 4096 * 2;
pub const chunk_size_usize: usize = 4096 * 2;
pub const amplitude: f64 = 5567.0; // volume
// a slice is a pointer

pub fn sinCreator(buffer: []u8, sr: u32, frequency: f64, allocator: std.mem.Allocator) !void {
    const buffer_len_float: f64 = @floatFromInt(buffer.len);
    const iter_num: f64 = buffer_len_float / chunk_size;
    const rest: f64 = @mod(buffer_len_float, iter_num) * 2;
    const iter_num_usize: usize = @intFromFloat(iter_num);
    const rest_usize: usize = @intFromFloat(rest);
    for (0..iter_num_usize + 1) |i| {
        if (i != iter_num_usize) {
            std.debug.print("reguar chunk \n", .{});
            const buff = try sinToBuff(chunk_size_usize, sr, frequency, allocator);
            @memcpy(buffer[i * chunk_size_usize .. i * chunk_size_usize + chunk_size_usize], buff);
            allocator.free(buff);
        } else {
            std.debug.print("end chunk \n", .{});
            const buff = try sinToBuff(rest_usize, sr, frequency, allocator);
            @memcpy(buffer[iter_num_usize * chunk_size_usize .. iter_num_usize * chunk_size_usize + rest_usize], buff);
            allocator.free(buff);
        }
    }
    try bufferToCSV(buffer);
    return;
}

pub fn sinToBuff(chunk_len: usize, sr: usize, frequency: f64, allocator: std.mem.Allocator) ![]u8 {
    const buff = try allocator.alloc(u8, chunk_len);
    for (0..chunk_len / 2) |i| {
        const sr_f64: f64 = @floatFromInt(sr);
        const if64: f64 = @floatFromInt(i);
        const time = if64 / sr_f64;
        const sin_val: f64 = @sin(2 * math.pi * time * frequency) * amplitude;
        const int16: i16 = @intFromFloat(sin_val);
        const bytes = tobytes(i16, int16);

        // smooth end of buffer
        if (i > @divFloor(chunk_len, 2)) {}
        buff[i * 2] = if (i > @divFloor(chunk_len, 3)) @bitReverse(bytes[0]) else bytes[0];
        buff[i * 2 + 1] = if (i > @divFloor(chunk_len, 3)) @bitReverse(bytes[1]) else bytes[1];
    }
    return buff;
}
