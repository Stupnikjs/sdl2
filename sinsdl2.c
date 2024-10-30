#include <SDL2/SDL.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>

#define SAMPLE_RATE 44100 // Samples per second
#define AMPLITUDE 128      // Amplitude of the wave (0 to 128 for signed 8-bit audio)
#define FREQUENCY 440      // Frequency of the sine wave in Hz
#define DURATION 5         // Duration in seconds

// Prototype for our audio callback
void my_audio_callback(void *userdata, Uint8 *stream, int len);

// Variable declarations
static Uint8 *audio_pos; // Global pointer to the audio buffer to be played
static Uint32 audio_len; // Remaining length of the sample we have to play

int main(int argc, char* argv[]) {
    // Initialize SDL
    if (SDL_Init(SDL_INIT_AUDIO) < 0) {
        fprintf(stderr, "SDL_Init Error: %s\n", SDL_GetError());
        return 1;
    }

    // Audio specification
    SDL_AudioSpec wav_spec;
    wav_spec.freq = SAMPLE_RATE;
    wav_spec.format = AUDIO_U8; // 8-bit unsigned audio
    wav_spec.channels = 1;       // Mono audio
    wav_spec.samples = 4096;     // Buffer size
    wav_spec.callback = my_audio_callback; // Set the callback function
    wav_spec.userdata = NULL;    // User data (not used here)

    // Open the audio device
    if (SDL_OpenAudio(&wav_spec, NULL) < 0) {
        fprintf(stderr, "Couldn't open audio: %s\n", SDL_GetError());
        SDL_Quit();
        return 1;
    }

    // Calculate the length of the audio buffer
    audio_len = SAMPLE_RATE * DURATION; // Total samples = Sample rate * Duration
    audio_pos = (Uint8 *)malloc(audio_len); // Allocate memory for the audio buffer

    // Generate the sine wave
    for (Uint32 i = 0; i < audio_len; i++) {
        audio_pos[i] = (Uint8)(AMPLITUDE * (sin(2.0 * M_PI * FREQUENCY * (i / (double)SAMPLE_RATE)) + 1) / 2); // Normalize to 0-255
    }

    // Start playing
    SDL_PauseAudio(0);

    // Wait until we're done playing
    while (audio_len > 0) {
        SDL_Delay(100);
    }

    // Shut everything down
    SDL_CloseAudio();
    free(audio_pos);
    SDL_Quit();

    return 0;
}

// Audio callback function
void my_audio_callback(void *userdata, Uint8 *stream, int len) {
    if (audio_len == 0) {
        return;
    }
    len = (len > audio_len ? audio_len : len); // Adjust length if needed
    SDL_memcpy(stream, audio_pos, len); // Copy audio data to stream
    audio_pos += len; // Move the position forward
    audio_len -= len; // Decrease the length remaining
}