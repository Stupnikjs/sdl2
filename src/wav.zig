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

    pub fn init(data_size: u32) WavObject {
        const riff_chunk_size_u32: u32 = 44 + data_size - 8; // Calculate the RIFF chunk size

        return WavObject{
            .riff_identifier = [_]u8{ 'R', 'I', 'F', 'F' },
            .riff_chunk_size = riff_chunk_size_u32,
            .riff_format = [_]u8{ 'W', 'A', 'V', 'E' },
            .fmt_identifier = [_]u8{ 'f', 'm', 't', ' ' },
            .fmt_subchunk_size = 16, // PCM format
            .fmt_audio_format = 1, // PCM (uncompressed)
            .fmt_num_channels = 2, // Stereo (for your example)
            .fmt_sample_rate = 44100,
            .fmt_byte_rate = 44100 * 2 * 16 / 8, // byte rate: sample_rate * num_channels * bits_per_sample / 8
            .fmt_block_size = 2 * 16 / 8, // Block size: channels * bits per sample / 8
            .fmt_bits_per_sample = 16, // 16 bits per sample
            .data_identifier = [_]u8{ 'd', 'a', 't', 'a' },
            .data_size = data_size,
        };
    }
    pub fn fromFile(filename: []const u8, allocator: std.mem.Allocator) !*WavObject {
        const file = try std.fs.cwd().openFile(filename, .{});
        defer file.close();
        const stat = try file.stat();
        const buff = try allocator.alloc(u8, stat.size - 44);
        try file.seekTo(44);
        _ = try file.read(buff);
        return buff;
    }
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
    pub fn deserializeHeader(wavBytes: []u8) !WavObject {
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
        std.mem.writeInt(u32, wavBytes[4..8], riffChunku32, endian);
        std.mem.writeInt(u32, wavBytes[16..20], subChunkSize, endian);
        std.mem.writeInt(u16, wavBytes[20..22], audioFormat, endian);
        std.mem.writeInt(u16, wavBytes[22..24], numChannels, endian);
        std.mem.writeInt(u32, wavBytes[24..28], sampleRate, endian);
        std.mem.writeInt(u32, wavBytes[28..32], byteRate, endian);
        std.mem.writeInt(u16, wavBytes[32..34], blockSize, endian);
        std.mem.writeInt(u16, wavBytes[34..36], bitsPerSample, endian);
        std.mem.writeInt(u32, wavBytes[40..44], dataSize, endian);

        return .{
            .riff_identifier = wavBytes[0..4],
            .riff_chunk_size = riffChunku32,
            .riff_format = wavBytes[8..12],
            .fmt_identifier = wavBytes[12..16],
            .fmt_subchunk_size = subChunkSize,
            .fmt_audio_format = audioFormat,
            .fmt_num_channels = numChannels,
            .fmt_sample_rate = sampleRate,
            .fmt_byte_rate = byteRate,
            .fmt_block_size = blockSize,
            .fmt_bits_per_sample = bitsPerSample,
            .data_identifier = wavBytes[36..40],
            .data_size = dataSize,
        };
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
