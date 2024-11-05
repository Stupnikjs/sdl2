const std = @import("std");
const builtin = @import("builtin");

pub fn intToBytes(T: type, source: T) []u8 {
    var buff: [@divExact(@typeInfo(T).int.bits, 8)]u8 = undefined;
    _ = std.mem.writeInt(T, &buff, source, builtin.cpu.arch.endian());
    return &buff;
}
