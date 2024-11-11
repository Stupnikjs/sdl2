const std = @import("std");
const math = std.math;
const tobytes = @import("types.zig").intToBytes;
const api = @import("sdl.zig");
const types = @import("types.zig");
const pow = math.pow;

pub fn getNoteFactor(tone_num: f64) f64 {
    return pow(f64, 2, (tone_num / 12));
}

pub fn playFull(main: f64) !void {
    const allocator = std.heap.page_allocator;
    var game: std.ArrayList(f64) = try std.ArrayList(f64).initCapacity(allocator, 12);

    for (0..12) |n| {
        const float_n: f64 = @floatFromInt(n);
        try game.append(main * getNoteFactor(float_n));
    }

    for (game.items, 0..game.items.len) |tone, i| {
        if (i % 2 == 0) {
            const params = types.SoundParams.init(44100, tone, 1024);
            std.debug.print("{d} \n", .{tone});
            try api.PlayAudio(params);
        }
    }
}
