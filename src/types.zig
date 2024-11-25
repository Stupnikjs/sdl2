const std = @import("std");
const builtin = @import("builtin");
const math = std.math;
const tobytes = @import("types.zig").intToBytes;
const api = @import("sdl.zig");
const types = @import("types.zig");
const pow = math.pow;

pub const bufferError = error{
    invalidLength,
};

pub const Instrument = enum {
    sinWave,
    squareWave,
    triangleWave,
    silence,
};

pub fn intToBytes(T: type, source: T) []u8 {
    var buff: [@divExact(@typeInfo(T).int.bits, 8)]u8 = undefined;
    _ = std.mem.writeInt(T, &buff, source, builtin.cpu.arch.endian());
    return &buff;
}

pub const SoundParams = struct {
    sr: usize,
    chunk_len: u16,
    amplitude: f64,
    allocator: std.mem.Allocator,
    pub fn init(sr: usize, chunk_len: u16, allocator: std.mem.Allocator) SoundParams {
        return .{
            .sr = sr,
            .chunk_len = chunk_len,
            .amplitude = 10000,
            .allocator = allocator,
        };
    }
};

pub const Note = struct {
    instrument: Instrument,
    note: f64,

    pub fn init(in: Instrument, note: f64) Note {
        return .{
            .instrument = in,
            .note = note,
        };
    }
    pub fn HalfToneDown(self: *Note) Note {
        return .{
            .instrument = self.instrument,
            .note = getNoteFactor(self.note, 1),
        };
    }
    pub fn FullToneDown(self: *Note) Note {
        return .{
            .instrument = self.instrument,
            .note = getNoteFactor(self.note, 2),
        };
    }
    pub fn PlayRange(self: *Note, up: bool, allocator: std.mem.Allocator) ![]Note {
        var list = std.ArrayList(Note).init(allocator);
        const direction: f64 = if (up) 1 else -1;
        for (0..7) |i| {
            switch (i) {
                0 => try list.append(Note.init(self.instrument, self.note)), // A
                1 => try list.append(Note.init(self.instrument, getNoteFactor(self.note, direction * 2))), // B
                2 => try list.append(Note.init(self.instrument, getNoteFactor(self.note, direction * 3))), // C
                3 => try list.append(Note.init(self.instrument, getNoteFactor(self.note, direction * 5))), // D
                4 => try list.append(Note.init(self.instrument, getNoteFactor(self.note, direction * 7))), // E
                5 => try list.append(Note.init(self.instrument, getNoteFactor(self.note, direction * 8))), // F
                6 => try list.append(Note.init(self.instrument, getNoteFactor(self.note, direction * 10))), // G
                else => break,
            }
        }
        return list.toOwnedSlice();
    }
};

pub const NoteLetter = enum {
    A,
    B, // Half tone
    C,
    D, // Half tone
    E,
    F,
    G,
};

pub fn getNoteFactor(note: f64, tone_num: f64) f64 {
    return note * pow(f64, 2, (tone_num / 12));
}
