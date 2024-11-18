const std = @import("std");
const testing = std.testing;
const types = @import("types.zig");
const Instrument = @import("instrument.zig").Instrument;
const Note = types.Note;

pub fn parseInput(allocator: std.mem.Allocator) ![]u8 {
    const input_buf: []u8 = try allocator.alloc(u8, 1024);

    const input = std.io.getStdIn().reader();
    const read_len = try input.read(input_buf);

    return input_buf[0..read_len];
}

pub fn inputToNote(input: []u8, allocator: std.mem.Allocator, main: f64) ![]Note {
    var noteList = std.ArrayList(Note).init(allocator);

    for (input) |c| {
        switch (c) {
            'A' => {
                const note = Note.init(.sinWave, main);
                try noteList.append(note);
            },
            'B' => {
                const note = Note.init(.sinWave, types.getNoteFactor(main, 2));
                try noteList.append(note);
            },
            'C' => {
                const note = Note.init(.sinWave, types.getNoteFactor(main, 3));
                try noteList.append(note);
            },
            'D' => {
                const note = Note.init(.sinWave, types.getNoteFactor(main, 5));
                try noteList.append(note);
            },
            'E' => {
                const note = Note.init(.sinWave, types.getNoteFactor(main, 6));
                try noteList.append(note);
            },
            'F' => {
                const note = Note.init(.sinWave, types.getNoteFactor(main, 8));
                try noteList.append(note);
            },
            'G' => {
                const note = Note.init(.sinWave, types.getNoteFactor(main, 10));
                try noteList.append(note);
            },
            else => return noteList.toOwnedSlice(),
        }
    }
    return noteList.toOwnedSlice();
}

test "simple input" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = gpa.allocator();

    const input_buf = try parseInput(allocator);
    defer allocator.free(input_buf);

    try testing.expect(input_buf.len == 1);
}
