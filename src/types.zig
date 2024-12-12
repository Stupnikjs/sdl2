const std = @import("std");
const builtin = @import("builtin");
const math = std.math;
const tobytes = @import("types.zig").intToBytes;
const api = @import("/sdl/sdl.zig");
const types = @import("types.zig");
const pow = math.pow;

pub const bufferError = error{
    invalidLength,
};

pub const Instrument = enum {
    sinWave,
    squareWave,
    triangleWave,
    kick,
    silence,
};

// mooves to util
pub fn intToBytes(T: type, source: T) []u8 {
    var buff: [@divExact(@typeInfo(T).int.bits, 8)]u8 = undefined;
    _ = std.mem.writeInt(T, &buff, source, builtin.cpu.arch.endian());
    return &buff;
}

// to audio
pub const SoundParams = struct {
    sr: usize,
    chunk_len: u16,
    amplitude: f64,
    frequency: f64,
    instrument: Instrument,
    allocator: std.mem.Allocator,
    pub fn init(sr: usize, chunk_len: u16, amplitude: f64, frequency: f64, instrument: Instrument, allocator: std.mem.Allocator) SoundParams {
        return .{
            .sr = sr,
            .chunk_len = chunk_len,
            .amplitude = amplitude,
            .frequency = frequency,
            .instrument = instrument,
            .allocator = allocator,
        };
    }
    pub fn default() SoundParams {
        return .{
            .sr = 44100,
            .chunk_len = 1024,
            .amplitude = 4000,
            .frequency = 440,
            .instrument = Instrument.sineWave,
            .allocator = std.heap.page_allocator,
        };
    }
};

pub const Note = struct {
    instrument: Instrument,
    note: f64,
    shift: bool,

    pub fn init(in: Instrument, note: f64, shift: bool) Note {
        return .{
            .instrument = in,
            .note = note,
            .shift = shift,
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
                0 => try list.append(Note.init(self.instrument, self.note, false)), // A
                1 => try list.append(Note.init(self.instrument, getNoteFactor(self.note, direction * 2), false)), // B
                2 => try list.append(Note.init(self.instrument, getNoteFactor(self.note, direction * 3), true)), // C
                3 => try list.append(Note.init(self.instrument, getNoteFactor(self.note, direction * 5), false)), // D
                4 => try list.append(Note.init(self.instrument, getNoteFactor(self.note, direction * 7), true)), // E
                5 => try list.append(Note.init(self.instrument, getNoteFactor(self.note, direction * 8), false)), // F
                6 => try list.append(Note.init(self.instrument, getNoteFactor(self.note, direction * 10), false)), // G
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
