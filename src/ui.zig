const std = @import("std");
const SDL = @import("sdl.zig").SDL;
const types = @import("types.zig");
const PlayBuffer = @import("sdl.zig").PlayBuffer;

const rec_size: c_int = 200;
const window_width: c_int = 500;
const window_height: c_int = 500;

// création d'une sequence d'instrument avec
// des effets
// bouton pour exporter en .wav
// bouton pour jouer le morceau

pub const ObjectShape = enum {
    Rectangle,
    Triangle,
    Line,
};
pub const Color = enum {
    yellow,
    black,
    red,
    blue,
    purple,
};

pub fn getRgbFromColor(color: Color) [4]u8 {
    switch (color) {
        .yellow => return [_]u8{ 255, 255, 0, 255 }, // RGBA for yellow
        .black => return [_]u8{ 0, 0, 0, 255 }, // RGBA for black
        .red => return [_]u8{ 255, 0, 0, 255 }, // RGBA for red
        .blue => return [_]u8{ 0, 0, 255, 255 }, // RGBA for blue
        .purple => return [_]u8{ 128, 0, 128, 255 }, // RGBA for purple
    }
}

pub fn uiWrapper() !void {
    if (SDL.SDL_Init(SDL.SDL_INIT_VIDEO) != 0) {
        return error.SDLInitFailed;
    }
    defer SDL.SDL_Quit();

    // Create a Window
    const Window = SDL.SDL_CreateWindow(
        "michel",
        SDL.SDL_WINDOWPOS_CENTERED,
        SDL.SDL_WINDOWPOS_CENTERED,
        window_width,
        window_height,
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

    _ = SDL.SDL_SetRenderDrawColor(renderer, 100, 30, 200, 255);

    _ = SDL.SDL_RenderDrawLine(renderer, 0, 0, 30, 300);

    const buffer = [_]u8{ 1, 3, 4, 34 };
    for (buffer, 0..buffer.len) |b, i| {
        const x: c_int = @intCast(i);
        const y: c_int = @intCast(b);
        _ = SDL.SDL_RenderDrawLine(renderer, 0, 0, x, y);
        _ = SDL.SDL_RenderDrawPoint(renderer, x, y);
    }

    SDL.SDL_RenderPresent(renderer);
    // Set the render draw color to black (R: 0, G: 0, B: 0, A: 255) and clear the screen

    _ = SDL.SDL_RenderClear(renderer);

    defer SDL.SDL_DestroyRenderer(renderer);
    // Wait before exiting
    std.time.sleep(10 * std.time.ns_per_s);
}
