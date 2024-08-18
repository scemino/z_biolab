const std = @import("std");
const zi = @import("zimpact");
const game = @import("../game.zig");
const Entity = game.Entity;
const vec2 = zi.vec2;
const engine = zi.Engine(game.Entity, game.EntityKind);

fn draw(self: *Entity, _: zi.Vec2) void {
    self.base.draw_order = 64;
    self.entity.end_hub_fade.time += @as(f32, @floatCast(zi.engine.tick));
    const color = zi.rgba(255, 255, 255, @min(@as(usize, @intFromFloat(255 * self.entity.end_hub_fade.time)), 255));
    const size = zi.types.fromVec2i(zi.render.renderSize());
    zi.render.draw(vec2(0, 0), size, zi.render.NO_TEXTURE, vec2(0, 0), vec2(0, 0), color);
}

pub var vtab: zi.EntityVtab(Entity) = .{
    .draw = draw,
};
