//csv file helper and plotter
// sound effect
const std = @import("std");
const math = std.math;
const int = @import("int.zig");
const tobytes = int.intToBytes;
const bufferError = @import("types.zig").bufferError;

pub fn bufferToCSV(buffer: []u8) !void {
    if (buffer.len % 2 != 0) return bufferError.invalidLength;
    const file = try std.fs.cwd().createFile("buf.csv", .{});

    for (0..buffer.len / 2) |i| {
        const first = buffer[i * 2];
        const sec = buffer[i * 2 + 1];
        const buff: [2]u8 = [2]u8{ first, sec };
        const sample: i16 = std.mem.bytesToValue(i16, &buff);
        var intStr: [6]u8 = undefined;
        _ = try std.fmt.bufPrint(&intStr, "{}", .{sample});
        _ = try file.write(&intStr);
        const space: [1]u8 = [1]u8{'\n'};
        _ = try file.write(&space);
    }

    file.close();
}
