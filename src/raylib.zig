const ray = @cImport({
    @cInclude("raylib.h");
    @cInclude("raymath.h");
    @cInclude("rlgl.h");
});
const std = @import("std");
const y_rect: c_int = 200;
const rect_width: c_int = 50;
const rect_heigth: c_int = 50;

pub fn ray_main() !void {

    // const monitor = ray.GetCurrentMonitor();
    // const width = ray.GetMonitorWidth(monitor);
    // const height = ray.GetMonitorHeight(monitor);

    const width = 800;
    const height = 450;

    ray.SetConfigFlags(ray.FLAG_MSAA_4X_HINT | ray.FLAG_VSYNC_HINT);
    ray.InitWindow(width, height, "zig raylib example");
    defer ray.CloseWindow();

    var gpa = std.heap.GeneralPurposeAllocator(.{ .stack_trace_frames = 8 }){};
    // const allocator = gpa.allocator();
    defer {
        switch (gpa.deinit()) {
            .leak => @panic("leaked memory"),
            else => {},
        }
    }

    // this are colors vars
    const colors = [_]ray.Color{ ray.GRAY, ray.RED, ray.BLACK, ray.LIME, ray.BLUE, ray.VIOLET, ray.BROWN };
    const colors_len: i32 = @intCast(colors.len);
    var current_color: i32 = 2;
    var hint = true;

    // this is recangle var

    while (!ray.WindowShouldClose()) {
        // input
        var delta: i2 = 0;
        if (ray.IsKeyPressed(ray.KEY_UP)) delta += 1;
        if (ray.IsKeyPressed(ray.KEY_DOWN)) delta -= 1;
        if (delta != 0) {
            current_color = @mod(current_color + delta, colors_len);
            hint = false;
        }

        // draw
        {
            ray.BeginDrawing();
            defer ray.EndDrawing();

            ray.ClearBackground(colors[@intCast(current_color)]);
            // if (hint) ray.DrawText("press up or down arrow to change background color", 120, 140, 20, ray.BLUE);
            // ray.DrawText("Congrats! You created your first window!", 190, 200, 20, ray.BLACK);

            ray.DrawRectangle(10, y_rect, rect_width, rect_heigth, ray.PURPLE);
            ray.DrawRectangle(20, y_rect, rect_width, rect_heigth, ray.PURPLE);
            ray.DrawRectangle(60, y_rect, rect_width, rect_heigth, ray.PURPLE);
            ray.DrawRectangle(110, y_rect, rect_width, rect_heigth, ray.PURPLE);
            ray.DrawRectangle(10, y_rect, rect_width, rect_heigth, ray.PURPLE);

            // now lets use an allocator to create some dynamic text
            // pay attention to the Z in `allocPrintZ` that is a convention
            // for functions that return zero terminated strings
            // const seconds: u32 = @intFromFloat(ray.GetTime());
            // const dynamic = try std.fmt.allocPrintZ(allocator, "running since {d} seconds", .{seconds});
            // defer allocator.free(dynamic);
            // ray.DrawText(dynamic, 300, 250, 20, ray.WHITE);
            // ray.DrawFPS(width - 100, 10);
        }
    }
}

fn hints() !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("\n⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯\n", .{});
    try stdout.print("Here are some hints:\n", .{});
    try stdout.print("Run `zig build --help` to see all the options\n", .{});
    try stdout.print("Run `zig build -Doptimize=ReleaseSmall` for a small release build\n", .{});
    try stdout.print("Run `zig build -Doptimize=ReleaseSmall -Dstrip=true` for a smaller release build, that strips symbols\n", .{});
    try stdout.print("Run `zig build -Draylib-optimize=ReleaseFast` for a debug build of your application, that uses a fast release of raylib (if you are only debugging your code)\n", .{});

    try bw.flush(); // don't forget to flush!
}

pub fn RectangleBuilder(n: usize) void {
    for (0..n) |i| {
        const x: c_int = @intCast(i);
        ray.DrawRectangle(x + 10, y_rect, rect_width, rect_heigth, ray.PURPLE);
    }
}
