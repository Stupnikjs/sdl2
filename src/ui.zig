const std = @import("std");
const SDL = @import("sdl.zig").SDL;
const types = @import("types.zig");
const PlayBuffer = @import("sdl.zig").PlayBuffer;

const rec_size: c_int = 50;
const window_width: c_int = 500;
const window_height: c_int = 500;

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

pub fn uiWrapper(buff: []u8) !void {
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

    // Set the render draw color to black (R: 0, G: 0, B: 0, A: 255) and clear the screen
    _ = SDL.SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
    _ = SDL.SDL_RenderClear(renderer);

    // Create a rectangle to draw (position x, y, width, height)
    const rect = SDL.SDL_Rect{
        .x = rec_size,
        .y = rec_size,
        .w = rec_size,
        .h = rec_size,
    };
    try buildRec(renderer.?, rect, Color.yellow);
    // Render the yellow rectangle
    SDL.SDL_RenderPresent(renderer);
    var exit = false;
    while (!exit) {
        var event: SDL.SDL_Event = undefined;
        // Handle events
        while (SDL.SDL_PollEvent(&event) != 0) {
            switch (event.common.type) {
                SDL.SDL_QUIT => exit = true,
                SDL.SDL_MOUSEBUTTONDOWN => {
                    if (isMouseInRect(event.button.x, event.button.y, rect)) {
                        const params = types.SoundParams.init(44100, 1024, std.heap.page_allocator);
                        try PlayBuffer(buff, params);
                    }
                },
                else => {
                    std.debug.print("is called", .{});
                },
            }
        }
    }
    defer SDL.SDL_DestroyRenderer(renderer);
    // Wait before exiting
    std.time.sleep(10 * std.time.ns_per_s);
}

pub fn buildRec(renderer: *SDL.SDL_Renderer, rec: SDL.SDL_Rect, color: Color) !void {
    // Set the render draw color to yellow (R: 255, G: 255, B: 0, A: 255)
    const r_color = getRgbFromColor(color);
    if (SDL.SDL_SetRenderDrawColor(renderer, r_color[0], r_color[1], r_color[2], r_color[3]) != 0) {
        return error.SetRenderColorFailed;
    }
    _ = SDL.SDL_RenderFillRect(renderer, &rec);
}

pub fn isMouseInRect(mx: i32, my: i32, rec: SDL.SDL_Rect) bool {
    if (mx > rec.x and my > rec.y and mx < rec.x + rec.w and my < rec.y + rec.h) return true else return false;
}
