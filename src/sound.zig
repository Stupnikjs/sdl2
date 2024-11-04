// sound effect
const std = @import("std");
const math = std.math;
const int = @import("int.zig");
const tobytes = int.intToBytes;
const bufferError = @import("types.zig").bufferError;
const bufferToCSV = @import("csv.zig").bufferToCSV;
const SoundParams = @import("types.zig").SoundParams;

// a slice is a pointer

pub fn sinCreator(buffer: []u8, params: SoundParams, allocator: std.mem.Allocator) !void {
    const buffer_len_float: f64 = @floatFromInt(buffer.len);
    std.debug.print("buffer len {d}\n", .{buffer.len});
    const chunk_size_usize: usize = @intCast(params.chunk_len * 2);
    const chunk_size_f64: f64 = @floatFromInt(chunk_size_usize);
    const iter_num: f64 = buffer_len_float / chunk_size_f64;
    const rest: f64 = @mod(buffer_len_float, iter_num) * 2;
    const iter_num_usize: usize = @intFromFloat(iter_num);
    const rest_usize: usize = @intFromFloat(rest);
    const sin_offset: *f64 = try allocator.create(f64);
    sin_offset.* = 0;
    defer allocator.destroy(sin_offset);
    for (0..iter_num_usize + 1) |i| {
        if (i != iter_num_usize) {
            std.debug.print("reguar chunk \n", .{});
            const buff = try sinToBuff(chunk_size_usize, sin_offset, params, allocator);
            @memcpy(buffer[i * chunk_size_usize .. i * chunk_size_usize + chunk_size_usize], buff);
            allocator.free(buff);
        } else {
            const buff = try sinToBuff(rest_usize, sin_offset, params, allocator);
            if (rest_usize != buff.len) @panic("here i go");
            std.debug.print("len {d} : {d} \n", .{ rest_usize, buff.len });
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
    for (0..buffer_len / 2) |i| {
        const sr_f64: f64 = @floatFromInt(params.sr);
        const if64: f64 = @floatFromInt(i);
        const note: f64 = @floatFromInt(params.frequency);
        const sin_arg: f64 = if64 * 2 * math.pi * note / sr_f64;
        const offset: f64 = sin_offset.*;
        const sin_val: f64 = @sin(offset + sin_arg);
        const int16: i16 = @intFromFloat(sin_val * params.amplitude);
        const bytes = tobytes(i16, int16);
        sin_offset.* = sin_val;
        // buff[i * 2] = if (i > @divFloor(chunk_len, 3)) @bitReverse(bytes[0]) else bytes[0];
        buff[i * 2] = bytes[0];
        buff[i * 2 + 1] = bytes[1];
    }

    return buff;
}
