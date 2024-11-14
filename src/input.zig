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
        std.debug.print("{c} \n", .{c});
        blk: {
            switch (c) {
                'A' => {
                    const note: Note = Note.init(Instrument.squareWave, main);
                    try noteList.append(note);
                },
                'B' => {
                    const note: Note = Note.init(Instrument.squareWave, types.getNoteFactor(main, 2));
                    try noteList.append(note);
                },
                'C' => {
                    const note: Note = Note.init(Instrument.squareWave, types.getNoteFactor(main, 3));
                    try noteList.append(note);
                },
                'D' => {
                    const note: Note = Note.init(Instrument.squareWave, types.getNoteFactor(main, 5));
                    try noteList.append(note);
                },
                'E' => {
                    const note: Note = Note.init(Instrument.squareWave, types.getNoteFactor(main, 7));
                    try noteList.append(note);
                },
                'F' => {
                    const note: Note = Note.init(Instrument.squareWave, types.getNoteFactor(main, 8));
                    try noteList.append(note);
                },
                'G' => {
                    const note: Note = Note.init(Instrument.squareWave, types.getNoteFactor(main, 10));
                    try noteList.append(note);
                },
                '\n' => {
                    break :blk;
                },
                ' ' => {
                    break :blk;
                },
                else => return error.invalidLength,
            }
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
