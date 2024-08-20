const std = @import("std");
const zi = @import("zimpact");
const game = @import("../game.zig");
const Entity = game.Entity;
const EntityVtab = zi.EntityVtab;
const vec2 = zi.vec2;
const engine = zi.Engine(game.Entity);

fn init(self: *Entity) void {
    self.base.size = vec2(4, 4);
    self.base.offset = vec2(0, 0);
    self.base.physics = zi.entity.ENTITY_PHYSICS_LITE;
    self.base.friction = vec2(0.25, 0);
    self.base.restitution = zi.utils.randFloat(0.5, 0.8);
    self.entity.particle.life_time = zi.utils.randFloat(2.0, 5.0);
    self.entity.particle.fade_time = 6;
}

fn update(self: *Entity) void {
    self.entity.particle.life_time -= @as(f32, @floatCast(zi.engine.tick));

    if (self.entity.particle.life_time < 0) {
        engine.entityKill(self);
        return;
    }
    self.base.anim.color.setA(std.math.clamp(
        @min(255, @as(usize, @intFromFloat(@floor(zi.utils.scale(self.entity.particle.life_time, 0.0, self.entity.particle.fade_time, 0.0, 255.0))))),
        0,
        255,
    ));
    engine.baseUpdate(self);
}

pub const vtab: EntityVtab(Entity) = .{
    .init = init,
    .update = update,
};
