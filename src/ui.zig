const std = @import("std");
const SDL = @import("sdl.zig").SDL;
const types = @import("types.zig");
const buf = @import("buf.zig");
const PlayBuffer = @import("sdl.zig").SDL_PlayBuffer;

const rec_size: c_int = 200;
const window_width: c_int = 600;
const window_height: c_int = 600;

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

pub fn uiWrapper(buffer: []u8, params: types.SoundParams) !void {
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
    eventLoop(renderer.?, buffer, params);
    // Set the render draw color to black (R: 0, G: 0, B: 0, A: 255) and clear the screen

    defer SDL.SDL_DestroyRenderer(renderer);
    std.time.sleep(1000 * std.time.ns_per_s);
}
pub fn BufferPlot(renderer: *SDL.SDL_Renderer, buffer: []u8) !void {
    const allocator = std.heap.page_allocator;
    var buff16 = try buf.buffu8ToI16(buffer, allocator);
    buff16 = try buf.normalizeBuff(i16, buff16, allocator, 300);
    defer allocator.free(buff16);
    const Ax = renderAxes(renderer, 20);

    _ = SDL.SDL_SetRenderDrawColor(renderer, 255, 0, 255, 255);

    var last_point_x: c_int = 0;
    var last_point_y: c_int = 0;
    const len: usize = if (buff16.len > window_width) window_width else buff16.len;
    for (0..len) |i| {
        const c_i: c_int = @intCast(i);
        const c_y: c_int = @intCast(buff16[i]);

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

pub fn RenderExitButton(renderer: *SDL.SDL_Renderer, size: c_int) SDL.SDL_Rect {
    const rectButton = SDL.SDL_Rect{
        .x = 0,
        .y = 0,
        .h = size,
        .w = size,
    };
    _ = SDL.SDL_SetRenderDrawColor(renderer, 255, 0, 0, 255);
    _ = SDL.SDL_RenderFillRect(renderer, &rectButton);
    return rectButton;
}
pub fn RenderPlayButton(renderer: *SDL.SDL_Renderer, size: c_int) SDL.SDL_Rect {
    const rectButton = SDL.SDL_Rect{
        .x = window_width - size,
        .y = 0,
        .h = size,
        .w = size,
    };
    _ = SDL.SDL_SetRenderDrawColor(renderer, 0, 0, 255, 255);
    _ = SDL.SDL_RenderFillRect(renderer, &rectButton);
    return rectButton;
}

pub fn isMouseInRec(event: SDL.SDL_Event, rect: SDL.SDL_Rect) bool {
    if (event.button.x > rect.x and
        event.button.x < rect.w + rect.x and
        event.button.y > rect.y and
        event.button.y < rect.h + rect.y)
    {
        return true;
    }
    return false;
}

pub fn eventLoop(renderer: *SDL.SDL_Renderer, buffer: []u8, params: types.SoundParams) void {
    const exitRect = RenderExitButton(renderer, 20);
    const playRect = RenderPlayButton(renderer, 20);
    SDL.SDL_RenderPresent(renderer);

    _ = SDL.SDL_RenderClear(renderer);
    // render all element
    // maybe call again for dynamic content
    var exit = false;
    var event: SDL.SDL_Event = undefined;
    while (!exit) {

        // Handle events
        while (SDL.SDL_PollEvent(&event) != 0) {
            switch (event.type) {
                SDL.SDL_QUIT => {
                    exit = true;
                    break;
                },
                SDL.SDL_MOUSEBUTTONDOWN => {
                    if (isMouseInRec(event, exitRect)) {
                        SDL.SDL_Quit();
                        std.process.exit(1);
                        break;
                    }
                    if (isMouseInRec(event, playRect)) {
                        std.debug.print("playing sound", .{});
                        try PlayBuffer(buffer, params);
                    }
                },
                else => {},
            }
        }
    }
}
