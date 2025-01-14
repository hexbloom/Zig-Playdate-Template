const std = @import("std");
const pdapi = @import("playdate_api_definitions.zig");
const panic_handler = @import("panic_handler.zig");

pub const panic = panic_handler.panic;

const ExampleGlobalState = struct {
    playdate: *pdapi.PlaydateAPI,
    playdate_image: *pdapi.LCDBitmap,
};

pub export fn eventHandler(playdate: *pdapi.PlaydateAPI, event: pdapi.PDSystemEvent, arg: u32) callconv(.C) c_int {
    //TODO: replace with your own code!

    _ = arg;
    switch (event) {
        .EventInit => {
            //NOTE: Initalizing the panic handler should be the first thing that is done.
            //      If a panic happens before calling this, the simulator or hardware will
            //      just crash with no message.
            panic_handler.init(playdate);

            const playdate_image = playdate.graphics.loadBitmap("images/playdate_image", null).?;
            const font = playdate.graphics.loadFont("/System/Fonts/Asheville-Sans-14-Bold.pft", null).?;
            playdate.graphics.setFont(font);

            const global_state: *ExampleGlobalState =
                @ptrCast(
                @alignCast(
                    playdate.system.realloc(
                        null,
                        @sizeOf(ExampleGlobalState),
                    ),
                ),
            );
            global_state.* = .{
                .playdate = playdate,
                .playdate_image = playdate_image,
            };

            playdate.system.setUpdateCallback(update_and_render, global_state);
        },
        else => {},
    }
    return 0;
}

fn update_and_render(userdata: ?*anyopaque) callconv(.C) c_int {
    //TODO: replace with your own code!

    const global_state: *ExampleGlobalState = @ptrCast(@alignCast(userdata.?));
    const playdate = global_state.playdate;
    const playdate_image = global_state.playdate_image;

    const to_draw = "Hello from Zig!";

    playdate.graphics.clear(@intFromEnum(pdapi.LCDSolidColor.ColorWhite));
    const pixel_width = playdate.graphics.drawText(to_draw, to_draw.len, .UTF8Encoding, 0, 0);
    _ = pixel_width;
    playdate.graphics.drawBitmap(playdate_image, pdapi.LCD_COLUMNS / 2 - 16, pdapi.LCD_ROWS / 2 - 16, .BitmapUnflipped);

    //returning 1 signals to the OS to draw the frame.
    //we always want this frame drawn
    return 1;
}
