const std = @import("std");

/// Represents the header of a WAV audio file.
/// See https://www-mmsp.ece.mcgill.ca/Documents/AudioFormats/WAVE/WAVE.html for the WAV file format specification.
pub const WavHeader = struct {
    /// Chunk identifier: "RIFF"
    riff_identifier: [4]u8 = "RIFF",

    /// Chunk size (file size - 8 bytes)
    riff_chunk_size: u32 = 0,

    /// Format identifier: "WAVE"
    riff_format: [4]u8 = "WAVE",

    /// Format subchunk identifier: "fmt "
    fmt_subchunk_identifier: [4]u8 = "fmt ",

    /// Subchunk size (16 for PCM)
    fmt_subchunk_size: u32 = 16,

    /// Audio format (1 for PCM)
    fmt_audio_format: u16 = 1,

    /// Number of channels (1 for mono, 2 for stereo)
    fmt_num_channels: u16 = 2,

    /// Sample rate (samples per second)
    fmt_sample_rate: u32 = 44100,

    /// Byte rate (sample rate * block size)
    fmt_byte_rate: u32 = 0,

    /// Block size (channels * bits per sample / 8)
    fmt_block_size: u16 = 0,

    /// Bits per sample (8 or 16)
    fmt_bits_per_sample: u16 = 16,

    /// Data subchunk identifier: "data"
    data_subchunk_identifier: [4]u8 = "data",

    /// Data subchunk size (size of the raw audio data)
    data_subchunk_size: u32 = 0,

    /// Initializes the WavHeader with default settings.
    fn init(self: *WavHeader) void {
        self.riff_chunk_size = 0;
        self.fmt_audio_format = 1;  // PCM
        self.fmt_num_channels = 2;  // stereo
        self.fmt_sample_rate = 44100;
        self.fmt_bits_per_sample = 16;
        self.fmt_block_size = (self.fmt_num_channels * self.fmt_bits_per_sample / 8);
        self.fmt_byte_rate = self.fmt_block_size * self.fmt_sample_rate;
    }
};
