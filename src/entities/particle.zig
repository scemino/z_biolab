const std = @import("std");
const zi = @import("zimpact");
const game = @import("../game.zig");
const Entity = zi.Entity;
const EntityVtab = zi.EntityVtab;
const vec2 = zi.vec2;
const engine = zi.Engine;

fn init(self: *Entity) void {
    self.size = vec2(4, 4);
    self.offset = vec2(0, 0);
    self.physics = zi.entity.ENTITY_PHYSICS_LITE;
    self.friction = vec2(0.25, 0);
    self.restitution = zi.utils.randFloat(0.5, 0.8);
    self.entity.particle.life_time = zi.utils.randFloat(2.0, 5.0);
    self.entity.particle.fade_time = 6;
}

fn update(self: *Entity) void {
    self.entity.particle.life_time -= @as(f32, @floatCast(zi.engine.tick));

    if (self.entity.particle.life_time < 0) {
        zi.entity.entityKill(self);
        return;
    }
    self.anim.color.setA(std.math.clamp(
        @min(255, @as(usize, @intFromFloat(@floor(zi.utils.scale(self.entity.particle.life_time, 0.0, self.entity.particle.fade_time, 0.0, 255.0))))),
        0,
        255,
    ));
    zi.entity.entityBaseUpdate(self);
}

pub const vtab: zi.EntityVtab = .{
    .init = init,
    .update = update,
};
