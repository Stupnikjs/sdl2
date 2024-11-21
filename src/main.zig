const std = @import("std");
const input = @import("input.zig");
const sdl = @import("sdl.zig");
const types = @import("types.zig");
const SoundParams = types.SoundParams;
const SDL = @import("sdl.zig").SDL;

pub fn main() !void {
    // Initialize SDL
    if (SDL.SDL_Init(SDL.SDL_INIT_VIDEO) != 0) {
        return error.SDLInitFailed;
    }
    defer SDL.SDL_Quit();

    // Create a Window
    const Window = SDL.SDL_CreateWindow(
        "michel",
        SDL.SDL_WINDOWPOS_CENTERED,
        SDL.SDL_WINDOWPOS_CENTERED,
        300,
        300,
        SDL.SDL_WINDOW_SHOWN,
    );
    if (Window == null) {
        return error.WindowCreationFailed;
    }
    defer SDL.SDL_DestroyWindow(Window);

    // Create a Renderer
    const renderer = SDL.SDL_CreateRenderer(Window, -1, SDL.SDL_RENDERER_ACCELERATED);
    if (renderer == null) {
        return error.RendererCreationFailed;
    }
    defer SDL.SDL_DestroyRenderer(renderer);

    // Set Render Draw Color
    if (SDL.SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255) != 0) {
        return error.RenderDrawColorFailed;
    }
    // Clear and Present Renderer
    _ = SDL.SDL_RenderClear(renderer);
    SDL.SDL_RenderPresent(renderer);

    // Wait before exiting
    std.time.sleep(10 * std.time.ns_per_s);
}

fn cli_note() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var in = try input.parseInput(allocator);
    while (true) {
        const arrNote = try input.inputToNote(in, allocator, 440);
        const params = SoundParams.init(44100, 1024, allocator);
        try sdl.PlayAudio(params, arrNote);
        in = try input.parseInput(allocator);
    }
}
