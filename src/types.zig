const std = @import("std");
const pow = std.math.pow;

pub const bufferError = error{
    invalidLength,
};

pub const SoundParams = struct {
    sr: usize,
    frequency: u32,
    chunk_len: u16,
    amplitude: f64,
    pub fn init(sr: usize, frequency: u32, chunk_len: u16, amplitude: f64) SoundParams {
        return .{
            .sr = sr,
            .frequency = frequency,
            .chunk_len = chunk_len,
            .amplitude = amplitude,
        };
    }
};

pub const Tone = struct {
    main: u32,
    // get the note
    pub fn getXToneNote(self: Tone, x: usize) u32 {
        const float_x: f64 = @floatFromInt(x);
        const float_main: f64 = @floatFromInt(self.main);
        const note_f64: f64 = float_main * pow(f64, 2, float_x / 12);
        std.debug.print("{d}", .{note_f64});
        return @intFromFloat(note_f64);
    }
};

// data types that act as a partition
// needs notes and the len of the note

pub const MusicSeq = struct {
    seq: []bool,

    pub fn init(len: usize, allocator: std.mem.Allocator) !MusicSeq {
        var sequence = try allocator.alloc(bool, len);
        for (0..len) |i| {
            if (i % 2 == 0) sequence[i] = true else sequence[i] = false;
        }
        return .{ .seq = sequence };
    }
};

test "initSeq" {
    const allocator = std.heap.page_allocator;
    const m_seq = try MusicSeq.init(6, allocator);
    std.debug.print("seq {any}", .{m_seq.seq});
    try std.testing.expect(m_seq.seq[2]);
}
