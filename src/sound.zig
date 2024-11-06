// sound effect
const std = @import("std");
const math = std.math;
const int = @import("int.zig");
const tobytes = int.intToBytes;
const bufferError = @import("types.zig").bufferError;
const bufferToCSV = @import("csv.zig").bufferToCSV;
const SoundParams = @import("types.zig").SoundParams;
const InstrumentToBuff = @import("instrument.zig").InstumentToBuff;
const Instrument = @import("instrument.zig").Instrument;

// a slice is a pointer
