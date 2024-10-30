const std = @import("std");
const tobytes = @import("int.zig").intToBytes;
const buildSin = @import("int.zig").buildSin;
const wrapper = @import("wrapper.zig"); 


pub fn main() !void {
   try wrapper.PlayAudio(15); 
}



