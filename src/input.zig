const std = @import("std");
const testing = std.testing;
const types = @import("types.zig");
const Instrument = @import("instrument.zig").Instrument;

pub fn parseInput(allocator: std.mem.Allocator) ![]u8 {
    const input_buf: []u8 = try allocator.alloc(u8, 1024);

    const input = std.io.getStdIn().reader();
    const read_len = try input.read(input_buf);

    return input_buf[0..read_len];
}

pub fn inputToNote(input: []u8, allocator: std.mem.Allocator) ![]Note {
    const noteList = std.ArrayList(Note).init(allocator);
    for (input) |c| {
        switch (c) {
            'A' => {
                const note: Note = Note.init(
                    Instrument.squareWave,
                );
                try noteList.append(note);
            },
            else => return error.invalidLength,
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
