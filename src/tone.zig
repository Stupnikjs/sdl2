const std = @import("std");
const math = std.math;
const tobytes = @import("types.zig").intToBytes;
const api = @import("sdl.zig");
const types = @import("types.zig");
const pow = math.pow;

pub fn getNoteFactor(note: f64, tone_num: f64) f64 {
    return note * pow(f64, 2, (tone_num / 12));
}

pub fn playFull(main: f64) !void {
    const params = types.SoundParams.init(44100, getNoteFactor(main, 6), 1024);
    try api.PlayAudio(params);
}
