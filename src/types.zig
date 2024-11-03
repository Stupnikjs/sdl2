pub const bufferError = error{
    invalidLength,
};

pub const SoundParams = struct {
    sr: usize,
    frequency: u32,
    chunk_len: u16,
    amplitude: u32,
    pub fn init(sr: usize, frequency: u32, chunk_len: u16, amplitude: u32) SoundParams {
        return .{
            .sr = sr,
            .frequency = frequency,
            .chunk_len = chunk_len,
            .amplitude = amplitude,
        };
    }
};
