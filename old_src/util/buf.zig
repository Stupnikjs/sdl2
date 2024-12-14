const std = @import("std");
const math = std.math;

pub fn normalizeBuff(T: type, buffer: []T, allocator: std.mem.Allocator, factor: f16) ![]T {
    var max: T = 0;
    var normalized = try allocator.alloc(i16, buffer.len);
    for (buffer) |val| {
        if (@abs(val) > max) max = val;
    }

    for (0..buffer.len) |i| {
        const val_float: f16 = @floatFromInt(buffer[i]);
        const max_float: f16 = @floatFromInt(max);
        normalized[i] = @intFromFloat(val_float / max_float * factor);
    }

    return normalized;
}

pub fn buffu8ToI16(buffer: []u8, allocator: std.mem.Allocator) ![]i16 {
    var new = try allocator.alloc(i16, buffer.len / 2);

    for (0..new.len) |i| {
        // only u8 to i16
        new[i] = sampleExtract(buffer[i * 2 .. i * 2 + 2]);
    }
    return new;
}

// can be more generics
pub fn sampleExtract(slice: []u8) i16 {
    const first = slice[0];
    const sec = slice[1];
    const buff: [2]u8 = [2]u8{ first, sec };
    const sample: i16 = std.mem.bytesToValue(i16, &buff);
    return sample;
}
