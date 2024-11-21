const std = @import("std");
const input = @import("input.zig");
const sdl = @import("sdl.zig");
const types = @import("types.zig");
const SoundParams = types.SoundParams;
const SDL = @import("sdl.zig").SDL;

const white_key_width: c_int = 50;
const white_key_height: c_int = 200;
const black_key_width: c_int = 50;
const black_key_height: c_int = 200;

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
        900,
        900,
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

    // Set the render draw color to black (R: 0, G: 0, B: 0, A: 255) and clear the screen
    _ = SDL.SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
    _ = SDL.SDL_RenderClear(renderer);

    // Set the render draw color to yellow (R: 255, G: 255, B: 0, A: 255)
    if (SDL.SDL_SetRenderDrawColor(renderer, 255, 255, 0, 255) != 0) {
        return error.SetRenderColorFailed;
    }

    // Create a rectangle to draw (position x, y, width, height)
    const rect = SDL.SDL_Rect{
        .x = 300,
        .y = 300,
        .w = 300,
        .h = 300,
    };

    // Render the yellow rectangle
    _ = SDL.SDL_RenderFillRect(renderer, &rect);

    // Present the rendered content
    SDL.SDL_RenderPresent(renderer);
    defer SDL.SDL_DestroyRenderer(renderer);

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
