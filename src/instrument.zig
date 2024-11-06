const std = @import("std")

// sin wave 
// square wave
// triangle wave 
// instruments put sound on some pos (seq)

// iterate over buffer and only write on
// buffers pos

pub fn sinToBuff(buffer_len: usize, sin_offset: *f64, params: SoundParams, allocator: std.mem.Allocator) ![]u8 {
    const buff = try allocator.alloc(u8, buffer_len);
    const sr_f64: f64 = @floatFromInt(params.sr);
    const note: f64 = @floatFromInt(params.frequency);

    // for each sample the arg of the sin is incremented
    // here is specificity of sin wave
    const phase_increment: f64 = 2 * math.pi * note / sr_f64;

    const fade_length: f64 = @floatFromInt(buffer_len / 5);
    for (0..buffer_len / 2) |i| {
        var fade_factor: f64 = 1.0;
        const float_i: f64 = @floatFromInt(i);
        if (i < fade_length) {
            // Fade-in (first fade_length samples)
            fade_factor = float_i / fade_length;
        } else if (i >= (buffer_len / 2) - fade_length) {
            // Fade-out (last fade_length samples)
            // fade_factor = @floatFromInt((buffer_len / 2) - i) / @floatFromInt(fade_length);
        }
        // float conversion

        const sin_val: f64 = @sin(sin_offset.*) * fade_factor;
        const int16: i16 = @intFromFloat(sin_val * params.amplitude);

        const bytes = tobytes(i16, int16);

        buff[i * 2] = if (i < buffer_len / 5) 1 else bytes[0];
        buff[i * 2 + 1] = if (i < buffer_len / 5) 1 else bytes[1];

        sin_offset.* += phase_increment;

        if (sin_offset.* >= 2.0 * math.pi) {
            sin_offset.* -= 2.0 * math.pi;
        }
    }
    return buff;
}