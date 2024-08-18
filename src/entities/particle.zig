const std = @import("std");
const zi = @import("zimpact");
const game = @import("../game.zig");
const Entity = game.Entity;
const EntityVtab = zi.EntityVtab;
const vec2 = zi.vec2;
const engine = zi.Engine(game.Entity, game.EntityKind);

fn init(self: *Entity) void {
    self.base.size = vec2(4, 4);
    self.base.offset = vec2(0, 0);
    self.base.physics = zi.entity.ENTITY_PHYSICS_LITE;
    self.base.friction = vec2(0.25, 0);
    self.base.restitution = zi.utils.rand_float(0.5, 0.8);
    self.base.particle.life_time = zi.utils.rand_float(2.0, 5.0);
    self.base.particle.fade_time = 6;
}

fn update(self: *Entity) void {
    self.particle.life_time -= engine.tick;

    if (self.particle.life_time < 0) {
        engine.killEntity(self);
        return;
    }
    self.anim.color.a = std.math.clamp(
        zi.scale(self.particle.life_time, 0, self.particle.fade_time, 0, 255),
        0,
        255,
    );
    engine.baseUpdate(self);
}

pub var vtab: EntityVtab(Entity) = .{
    .init = init,
    .update = update,
};
