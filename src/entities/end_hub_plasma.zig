// EDITOR_IGNORE(true);

const std = @import("std");
const zi = @import("zimpact");
const game = @import("../game.zig");
const g = @import("../global.zig");
const Entity = zi.Entity;
const vec2 = zi.vec2;

var img_plasma: *zi.Image = undefined;

fn load() void {
    img_plasma = zi.image("assets/sprites/plasma.qoi");
}

fn draw(self: *Entity, vp: zi.Vec2) void {
    self.entity.end_hub_plasma.time += @as(f32, @floatCast(zi.engine.tick));
    self.draw_order = 8;
    const d = self.entity.end_hub_plasma.time;
    const t = d * 100 + 16000;
    const i: f32 = @floatFromInt(self.entity.end_hub_plasma.index);
    const xn1 = g.noise.gen(vec2(i * (10.0 / 97.0), t * (1.0 / 883.0)));
    const xn2 = g.noise.gen(vec2(i * (10.0 / 41.0), t * (1.0 / 311.0))) * 2.0;
    const xn3 = g.noise.gen(vec2(i * (10.0 / 13.0), t * (1.0 / 89.0))) * 0.5;
    const yn1 = g.noise.gen(vec2(i * (10.0 / 97.0), t * (1.0 / 701.0)));
    const yn2 = g.noise.gen(vec2(i * (10.0 / 41.0), t * (1.0 / 373.0))) * 2.0;
    const yn3 = g.noise.gen(vec2(i * (10.0 / 13.0), t * (1.0 / 97.0))) * 0.5;

    const spread = std.math.clamp(80.0 / (d * d * 0.7), 0, 1000);
    const pos = vec2(self.pos.x + (xn1 + xn2 + xn3) * 40 * spread, self.pos.y + (yn1 + yn2 + yn3) * 30 * spread);

    zi.render.setBlendMode(.lighter);
    img_plasma.draw(pos.sub(vp));
    zi.render.setBlendMode(.normal);
}

pub const vtab: zi.EntityVtab = .{
    .load = load,
    .draw = draw,
};
