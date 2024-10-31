const std = @import("std");
const builtin = @import("builtin");

pub fn intToBytes(T: type, source: T) []u8 {
    var buff: [@divExact(@typeInfo(T).int.bits, 8)]u8 = undefined;
    _ = std.mem.writeInt(T, &buff, source, builtin.cpu.arch.endian());
    return &buff;
}

pub fn floatToInt(float: f32) u32 {
    const int: u32 = @intFromFloat(float);
    std.debug.print("{d}", .{int});
    return int;
}

pub fn buildSin(len: usize, allocator: std.mem.Allocator) ![]u8 {
    const newBuff = try allocator.alloc(u16, len);
    defer allocator.free(newBuff);
    const buffer = try allocator.alloc(u8, len * 2);

    for (0..len) |i| {
        const i_fl: f64 = @floatFromInt(i);
        const sinus: f64 = @trunc((std.math.sin(2 * std.math.pi * i_fl * 440) + 1));
        const normalized: u16 = @intFromFloat(sinus);
        newBuff[i] = normalized;
    }

    for (0..newBuff.len) |i| {
        const int = newBuff[i];
        const bytes = intToBytes(u16, int);
        buffer[i * 2] = bytes[0];
        buffer[i * 2 + 1] = bytes[1];
    }

    return buffer;
}
