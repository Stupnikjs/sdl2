const std = @import("std");
const types = @import("../types.zig");
const intToBytes = types.intToBytes;
const builtin = @import("builtin");
const endian = builtin.cpu.arch.endian();

/// Represents the header of a WAV audio file.
/// See https://www-mmsp.ece.mcgill.ca/Documents/AudioFormats/WAVE/WAVE.html for the WAV file format specification.
pub const WavObject = struct {
    riff_identifier: *[4]u8, // Chunk identifier: "RIFF"
    riff_chunk_size: u32, // Chunk size (file size - 8 bytes)
    riff_format: *[4]u8, // Format identifier: "WAVE"
    fmt_identifier: *[4]u8, // Format subchunk identifier: "fmt "
    fmt_subchunk_size: u32, // Subchunk size (16 for PCM)
    fmt_audio_format: u16, // Audio format (1 for PCM)
    fmt_num_channels: u16, // Number of channels (1 for mono, 2 for stereo)
    fmt_sample_rate: u32, // Sample rate (samples per second)
    fmt_byte_rate: u32, // Byte rate (sample rate * block size)
    fmt_block_size: u16, // Block size (channels * bits per sample  8)
    fmt_bits_per_sample: u16, //Bits per sample (8 or 16)
    data_identifier: *[4]u8, // Data subchunk identifier: "data"
    data_size: u32, // Data subchunk size (size of the raw audio data)

    pub fn serialize(self: *WavObject, allocator: std.mem.Allocator) ![]u8 {
        var header = try allocator.alloc(u8, 44);
        @memcpy(header[0..4], &self.riff_identifier);
        @memcpy(header[4..8], intToBytes(u32, self.riff_chunk_size));
        @memcpy(header[8..12], &self.riff_format);
        @memcpy(header[12..16], &self.fmt_identifier);
        @memcpy(header[16..20], intToBytes(u32, self.fmt_subchunk_size));
        @memcpy(header[20..22], intToBytes(u16, self.fmt_audio_format));
        @memcpy(header[22..24], intToBytes(u16, self.fmt_num_channels));
        @memcpy(header[24..28], intToBytes(u32, self.fmt_sample_rate));
        @memcpy(header[28..32], intToBytes(u32, self.fmt_byte_rate));
        @memcpy(header[32..34], intToBytes(u16, self.fmt_block_size));
        @memcpy(header[34..36], intToBytes(u16, self.fmt_bits_per_sample));
        @memcpy(header[36..40], &self.data_identifier);
        @memcpy(header[40..44], intToBytes(u32, self.data_size));

        return header;
    }
    pub fn deserializeHeader(wavBytes: []u8, allocator: std.mem.Allocator) !*WavObject {
        var wavObj = try allocator.create(WavObject);
        if (wavBytes.len < 44) return error.InvalidWav;

        const riffChunku32: u32 = undefined;
        const subChunkSize: u32 = undefined;
        const audioFormat: u16 = undefined;
        const numChannels: u16 = undefined;
        const sampleRate: u32 = undefined;
        const byteRate: u32 = undefined;
        const blockSize: u16 = undefined;
        const bitsPerSample: u16 = undefined;
        const dataSize: u32 = undefined;

        // Parse individual fields from the wavBytes array
        std.mem.writeInt(u32, wavBytes[4..8], riffChunku32, .little);
        std.mem.writeInt(u32, wavBytes[16..20], subChunkSize, .little);
        std.mem.writeInt(u16, wavBytes[20..22], audioFormat, .little);
        std.mem.writeInt(u16, wavBytes[22..24], numChannels, .little);
        std.mem.writeInt(u32, wavBytes[24..28], sampleRate, .little);
        std.mem.writeInt(u32, wavBytes[28..32], byteRate, .little);
        std.mem.writeInt(u16, wavBytes[32..34], blockSize, .little);
        std.mem.writeInt(u16, wavBytes[34..36], bitsPerSample, .little);
        std.mem.writeInt(u32, wavBytes[40..44], dataSize, .little);

        wavObj.riff_identifier = wavBytes[0..4];
        wavObj.riff_chunk_size = riffChunku32;
        wavObj.riff_format = wavBytes[8..12];
        wavObj.fmt_identifier = wavBytes[12..16];
        wavObj.fmt_subchunk_size = subChunkSize;
        wavObj.fmt_audio_format = audioFormat;
        wavObj.fmt_num_channels = numChannels;
        wavObj.fmt_sample_rate = sampleRate;
        wavObj.fmt_byte_rate = byteRate;
        wavObj.fmt_block_size = blockSize;
        wavObj.fmt_bits_per_sample = bitsPerSample;
        wavObj.data_identifier = wavBytes[36..40];
        wavObj.data_size = dataSize;
        return wavObj;
    }
    pub fn PrintHeader(self: WavObject) void {
        std.debug.print("chunk_size  {d} \n", .{self.fmt_subchunk_size});
        std.debug.print("riff_chunk_size {d} \n", .{self.riff_chunk_size});
        std.debug.print("num channels {d} \n", .{self.fmt_num_channels});
        std.debug.print("sample rate {d} \n", .{self.fmt_sample_rate});
        std.debug.print("byte_rate {d} \n", .{self.fmt_byte_rate});
        std.debug.print("block_size {d} \n", .{self.fmt_block_size});
        std.debug.print("fmt_bits_per_sample {d} \n", .{self.fmt_bits_per_sample});
        std.debug.print("data_size {d} \n", .{self.data_size});
    }

    pub fn WriteWav(self: *WavObject, buffer: []u8, filename: []const u8) !void {
        const file = try std.fs.cwd().createFile(filename, .{});
        defer file.close();
        var allocator = std.heap.page_allocator;
        var serialized = try allocator.alloc(u8, 44);
        defer allocator.free(serialized);
        serialized = try self.serialize(allocator);
        const header_size = try file.write(serialized[0..]);
        if (header_size != 44) return error.headerMalformed;
        _ = try file.write(buffer);
    }
};

pub fn bufferFromWav(filename: []const u8, allocator: std.mem.Allocator) ![]u8 {
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();
    const stat = try file.stat();
    const buff = try allocator.alloc(u8, stat.size - 44);
    try file.seekTo(44);
    _ = try file.read(buff);
    return buff;
}

pub fn PlayWav(filename: []const u8) !void {
    _ = filename;
}
