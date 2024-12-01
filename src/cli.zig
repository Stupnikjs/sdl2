// cli interface builder
const std = @import("std");
const strequal = std.mem.eql;

pub const mainCommand = enum {
    init,
    play,
    exit,
    reset,
    list,
    help,
    gen,
};

pub const Command = struct {
    main: ?mainCommand,
    arg: ?std.StringHashMap(u16),

    pub fn init() Command {
        return .{
            .main = null,
            .arg = null,
        };
    }
};

pub fn ParseUserInput(commandBuffer: []u8) !usize {
    const stdin = std.io.getStdIn().reader();
    const command = try stdin.read(commandBuffer);
    return command;
}

pub fn Parser(cmdstr: []u8, allocator: std.mem.Allocator) !Command {
    _ = allocator;
    // init + millisecond length
    // allocate a buffer of length
    // play command for listening for the sample
    // list instrument list effect
    // gen fill the buffer with sound
    // exit
    // reset reseting buffer
    // help
    // const command = try allocator.create(Command);
    var command = Command.init();
    try extractMainCmd(cmdstr, &command);
    return command;
}

pub fn extractMainCmd(cmdstr: []u8, command: *Command) !void {
    var list = std.ArrayList(u8).init(std.heap.page_allocator);
    defer list.deinit();
    for (cmdstr) |c| {
        if (c == ' ' or c == '\n') break else try list.append(c);
    }
    const main = try list.toOwnedSlice();
    std.debug.print("main {s}| \n", .{main});
    if (strequal(u8, main, "exit")) command.main = mainCommand.exit;
    if (strequal(u8, main, "help")) command.main = mainCommand.help;
    if (strequal(u8, main, "list")) command.main = mainCommand.list;
    if (strequal(u8, main, "play")) command.main = mainCommand.play;
    if (strequal(u8, main, "gen")) command.main = mainCommand.gen;
    if (strequal(u8, main, "init")) command.main = mainCommand.init;
    if (strequal(u8, main, "reset")) command.main = mainCommand.reset;

    std.debug.print("{any}", .{command});
}
