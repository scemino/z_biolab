const std = @import("std");
const zi = @import("zimpact");
const game = @import("../game.zig");
const g = @import("../global.zig");
const scene_game = @import("game.zig");
const title = @import("../scenes/title.zig");
const player = @import("../entities/player.zig");
const Scene = zi.Scene;
const Image = zi.Image;
const font = zi.font;
const Engine = zi.Engine(game.Entity, game.EntityKind);
const engine = zi.engine;
const scale = zi.utils.scale;
const vec2 = zi.vec2;

const credits =
    \\          Thanks for Playing!\n
    \\\n
    \\\n
    \\Concept Graphics & Programming\n
    \\    Dominic Szablewski\n
    \\\n
    \\Music\n
    \\    Andreas Loesch\n
    \\\n
    \\Beta Testing\n
    \\    Sebastian Gerhard\n
    \\    Benjamin Hartmann\n
    \\    Jos Hirth\n
    \\    David Jacovangelo\n
    \\    Tim Juraschka\n
    \\    Christopher Klink\n
    \\    Mike Neumann\n
    \\\n
    \\\n
    \\\n
    \\\n
    \\Made with high_impact\n
    \\github.com/phoboslab/high_impact
;

fn update() void {
    Engine.sceneBaseUpdate();

    if (zi.input.pressed(player.SHOOT) or zi.input.pressed(player.JUMP) or engine.time > 44) {
        Engine.setScene(&title.scene);
    }
}

fn draw() void {
    Engine.baseDraw();

    const color = zi.rgba(255, 255, 255, @max(255 - @as(u8, @intFromFloat(255 * engine.time)), 0));
    const size = zi.fromVec2i(zi.render.renderSize());
    zi.render.draw(vec2(0, 0), size, zi.render.NO_TEXTURE, vec2(0, 0), vec2(0, 0), color);

    const scroll: f32 = (@as(f32, @floatCast(engine.time)) - 3.5) * 10;
    g.font.draw(vec2(32, size.y - scroll), credits, .FONT_ALIGN_LEFT);
}

pub var scene: Scene = .{
    .update = update,
    .draw = draw,
};
