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
