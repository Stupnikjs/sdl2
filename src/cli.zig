// cli interface builder 
const std = @import("std"); 

pub fn ParseUserInput(allocator: std.mem.Allocator) ![]const u8 {
    const stdin = std.io.getStdIn().reader(); 
    stdin.readUntilDelimiterAlloc(allocator, '\n', 2048);  
    return command 
}; 