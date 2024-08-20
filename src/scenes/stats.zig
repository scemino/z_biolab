const std = @import("std");
const zi = @import("zimpact");
const game = @import("../game.zig");
const g = @import("../global.zig");
const scene_game = @import("game.zig");
const player = @import("../entities/player.zig");
const Scene = zi.Scene;
const Image = zi.Image;
const font = zi.font;
const Engine = zi.Engine(game.Entity);
const engine = zi.engine;
const scale = zi.utils.scale;
const vec2 = zi.vec2;

fn update() void {
    Engine.sceneBaseUpdate();

    if (zi.input.pressed(player.SHOOT) or zi.input.pressed(player.JUMP)) {
        Engine.setScene(&scene_game.scene);
    }
}

fn draw() void {
    Engine.baseDraw();

    var buf: [64]u8 = undefined;
    g.font.draw(vec2(@as(f32, @floatFromInt(zi.render.renderSize().x)) / 2.0, 20), "Level Complete!", .FONT_ALIGN_CENTER);
    g.font.draw(vec2(98, 56), "Time:", .FONT_ALIGN_RIGHT);
    var text = std.fmt.bufPrint(&buf, "{d:.2}s", .{g.level_time}) catch @panic("failed to format string");
    g.font.draw(vec2(104, 56), text, .FONT_ALIGN_LEFT);
    g.font.draw(vec2(98, 68), "Tubes Collected:", .FONT_ALIGN_RIGHT);
    text = std.fmt.bufPrint(&buf, "{}/{}", .{ g.tubes_collected, g.tubes_total }) catch @panic("failed to format string");
    g.font.draw(vec2(104, 68), text, .FONT_ALIGN_LEFT);
    g.font.draw(vec2(98, 80), "Deaths:", .FONT_ALIGN_RIGHT);
    text = std.fmt.bufPrint(&buf, "{}", .{g.death_count}) catch @panic("failed to format string");
    g.font.draw(vec2(104, 80), text, .FONT_ALIGN_LEFT);
    g.font.draw(vec2(@as(f32, @floatFromInt(zi.render.renderSize().x)) / 2.0, 140), "Press X or C to Proceed", .FONT_ALIGN_CENTER);
}

pub const scene: Scene = .{
    .update = update,
    .draw = draw,
};
