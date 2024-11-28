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

pub fn uiWrapper(buffer: []u8) !void {
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

    _ = SDL.SDL_SetRenderDrawColor(renderer, 255, 255, 0, 255);

    try BufferPlot(renderer.?, buffer);
    SDL.SDL_RenderPresent(renderer);
    // Set the render draw color to black (R: 0, G: 0, B: 0, A: 255) and clear the screen

    _ = SDL.SDL_RenderClear(renderer);

    defer SDL.SDL_DestroyRenderer(renderer);
    // Wait before exiting
    std.time.sleep(10 * std.time.ns_per_s);
}

pub fn BufferPlot(renderer: *SDL.SDL_Renderer, buffer: []u8) !void {
    _ = buffer;
    const Ax = renderAxes(renderer, 20);

    _ = SDL.SDL_SetRenderDrawColor(renderer, 255, 0, 255, 255);

    const testBuff = [_]u8{ 10, 40, 20, 0, 10, 50, 80, 120, 30 };
    var last_point_x: c_int = 0;
    var last_point_y: c_int = 0;
    for (0..testBuff.len) |i| {
        const c_i: c_int = @intCast(i * 50);
        const c_y: c_int = @intCast(testBuff[i]);

        // y is value of origin_y minus y
        // x is sum of x plus offset of origin x
        _ = SDL.SDL_RenderDrawLine(renderer, Ax.origin_x + last_point_x, Ax.y - last_point_y, Ax.origin_x + c_i, Ax.y - c_y);
        last_point_x = c_i;
        last_point_y = c_y;
    }
}

const Axes = struct { origin_x: c_int, top_x: c_int, y: c_int };
pub fn renderAxes(renderer: *SDL.SDL_Renderer, n: c_int) Axes {
    const origin_x = @divTrunc(window_width, n);
    const top_x = @divTrunc(window_width * (n - 1), n);
    const origin_y = @divTrunc(window_height, 2);
    _ = SDL.SDL_RenderDrawLine(renderer, origin_x, origin_y, top_x, origin_y);
    return .{
        .origin_x = origin_x,
        .top_x = top_x,
        .y = origin_y,
    };
}
pub fn sampleExtract(slice: []u8) i16 {
    const first = slice[0];
    const sec = slice[1];
    const buff: [2]u8 = [2]u8{ first, sec };
    const sample: i16 = std.mem.bytesToValue(i16, &buff);
    return sample;
}
