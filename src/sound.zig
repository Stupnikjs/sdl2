const std = @import("std");
const sdl = @import("sdl.zig");
const SoundParams = sdl.SoundParams;
const math = std.math;

pub const Instrument = enum {
    sinWave,
    squareWave,
    triangleWave,
    kick,
    silence,
};

pub fn calcWave(freq: f64, instrument: Instrument, sin_offset: *f64, sr_f64: f64, shift: f64) f64 {
    return switch (instrument) {
        Instrument.sinWave => sinFunc(sin_offset, freq, sr_f64, shift),
        Instrument.squareWave => squareFunc(sin_offset, freq, sr_f64, shift),
        Instrument.triangleWave => triangleFunc(sin_offset, freq, sr_f64, shift),
        Instrument.kick => sinFunc(sin_offset, freq, sr_f64, shift), // change this
        else => 0,
    };
}

// MATH FUNCTIONS TO BUILD THE WAVE

pub fn sinFunc(offset: *f64, note: f64, sr_f64: f64, shift: f64) f64 {
    const phase_increment: f64 = 2 * math.pi * note / sr_f64;
    const sin_val = @sin(offset.* + shift);
    offset.* += phase_increment;
    return sin_val;
}

pub fn squareFunc(offset: *f64, note: f64, sr_f64: f64, shift: f64) f64 {
    const phase_increment: f64 = 2 * math.pi * note / sr_f64;
    const sin_val: f64 = if (@sin(offset.* + shift) > 0) 1 else -1;
    offset.* += phase_increment;
    return sin_val;
}

pub fn triangleFunc(offset: *f64, note: f64, sr_f64: f64, shift: f64) f64 {
    const phase_increment: f64 = note / sr_f64;

    // Update the phase and wrap between 0.0 and 1.0
    offset.* = (@mod(offset.* + phase_increment + shift, 1.0));

    const phase = 2.0 * offset.* - 1.0;
    return if (phase < 0.0) -phase else phase;
}
