const std = @import("std");
const sdl = @import("sdl.zig");
const builtin = @import("builtin");
const endian = builtin.cpu.arch.endian();

/// Represents the header of a WAV audio file.
/// See https://www-mmsp.ece.mcgill.ca/Documents/AudioFormats/WAVE/WAVE.html for the WAV file format specification.
pub const WavHeader = struct {
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

    pub fn serialize(self: *WavHeader, allocator: std.mem.Allocator) ![]u8 {
        var header = try allocator.alloc(u8, 44);
        @memcpy(header[0..4], &self.riff_identifier);
        @memcpy(header[4..8], sdl.intToBytes(u32, self.riff_chunk_size));
        @memcpy(header[8..12], &self.riff_format);
        @memcpy(header[12..16], &self.fmt_identifier);
        @memcpy(header[16..20], sdl.intToBytes(u32, self.fmt_subchunk_size));
        @memcpy(header[20..22], sdl.intToBytes(u16, self.fmt_audio_format));
        @memcpy(header[22..24], sdl.intToBytes(u16, self.fmt_num_channels));
        @memcpy(header[24..28], sdl.intToBytes(u32, self.fmt_sample_rate));
        @memcpy(header[28..32], sdl.intToBytes(u32, self.fmt_byte_rate));
        @memcpy(header[32..34], sdl.intToBytes(u16, self.fmt_block_size));
        @memcpy(header[34..36], sdl.intToBytes(u16, self.fmt_bits_per_sample));
        @memcpy(header[36..40], &self.data_identifier);
        @memcpy(header[40..44], sdl.intToBytes(u32, self.data_size));

        return header;
    }
    pub fn deserializeHeader(wavBytes: []u8, allocator: std.mem.Allocator) !*WavHeader {
        std.debug.print("{d}", .{wavBytes[0..44]});
        var wavObj = try allocator.create(WavHeader);
        if (wavBytes.len < 44) return error.InvalidWav;

        // Parse individual fields from the wavBytes array
        const riffChunku32 = std.mem.readInt(u32, wavBytes[4..8], .little);
        const subChunkSize: u32 = std.mem.readInt(u32, wavBytes[16..20], .little);
        const audioFormat: u16 = std.mem.readInt(u16, wavBytes[20..22], .little);
        const numChannels: u16 = std.mem.readInt(u16, wavBytes[22..24], .little);
        const sampleRate: u32 = std.mem.readInt(u32, wavBytes[24..28], .little);
        const byteRate: u32 = std.mem.readInt(u32, wavBytes[28..32], .little);
        const blockSize: u16 = std.mem.readInt(u16, wavBytes[32..34], .little);
        const bitsPerSample: u16 = std.mem.readInt(u16, wavBytes[34..36], .little);
        const dataSize: u32 = std.mem.readInt(u32, wavBytes[40..44], .little);
        std.debug.print("size {d} \n", .{dataSize});
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
    pub fn PrintHeader(self: WavHeader) void {
        std.debug.print("chunk_size  {d} \n", .{self.fmt_subchunk_size});
        std.debug.print("riff_chunk_size {d} \n", .{self.riff_chunk_size});
        std.debug.print("num channels {d} \n", .{self.fmt_num_channels});
        std.debug.print("sample rate {d} \n", .{self.fmt_sample_rate});
        std.debug.print("byte_rate {d} \n", .{self.fmt_byte_rate});
        std.debug.print("block_size {d} \n", .{self.fmt_block_size});
        std.debug.print("fmt_bits_per_sample {d} \n", .{self.fmt_bits_per_sample});
        std.debug.print("data_size {d} \n", .{self.data_size});
    }

    pub fn SDLSPEC_FROMWAV(self: *WavHeader) sdl.SDL.SDL_AudioSpec {
        const sr_c_int: c_int = @intCast(self.fmt_sample_rate);
        const channels_u8: u8 = @intCast(self.fmt_num_channels);
        std.debug.print("audio_format {d}", .{self.fmt_audio_format});
        return sdl.SDL.SDL_AudioSpec{
            .freq = sr_c_int,
            .format = self.fmt_audio_format,
            .channels = channels_u8,
            .userdata = null,
            .callback = sdl.my_audio_callback,
        };
    }
    pub fn Play(self: *WavHeader, buffer: []u8) !void {
        var spec = self.SDLSPEC_FROMWAV();
        std.debug.print("spec {any}", .{spec});
        try sdl.SDL_PlayBuffer(buffer[44..].ptr, &spec);
    }
};

pub fn OpenWAVFileAllocated(filename: []const u8, allocator: std.mem.Allocator) ![]u8 {
    const file = try std.fs.cwd().openFile(filename, .{});
    const stat = try file.stat();
    const buffer = try allocator.alloc(u8, stat.size);
    const len = try file.readAll(buffer);
    if (len != buffer.len) return error.InvalidBufferLen;
    return buffer;
}
