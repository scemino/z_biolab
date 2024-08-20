const std = @import("std");
const zi = @import("zimpact");
const game = @import("../game.zig");
const Entity = game.Entity;
const vec2 = zi.vec2;
const vec2i = zi.vec2i;
const engine = zi.Engine(game.Entity);

var anim_idle: zi.AnimDef = undefined;

fn load() void {
    const sheet = zi.image("assets/sprites/elevator.qoi");

    anim_idle = zi.animDef(sheet, vec2i(24, 8), 1.0, &[_]u16{0}, true);
}

fn init(self: *Entity) void {
    self.base.anim = zi.anim(&anim_idle);
    self.base.size = vec2(24, 8);
    self.base.physics = zi.entity.ENTITY_PHYSICS_FIXED;
    self.base.gravity = 0;
    self.entity.mover.speed = 20;
}

fn settings(self: *Entity, s: std.json.ObjectMap) void {
    self.entity.mover.targets = engine.entitiesFromJsonNames(s.get("target").?.object);
    self.entity.mover.speed = zi.utils.jsonFloat(s.get("speed"));
    if (self.entity.mover.speed == 0) {
        self.entity.mover.speed = 20;
    }
}

fn update(self: *Entity) void {
    if (self.entity.mover.targets.items.len == 0) {
        return;
    }

    const target = engine.entityByRef(self.entity.mover.targets.items[self.entity.mover.current_target]);

    const prev_distance = engine.entityDist(self, target.?);
    const angle = engine.entityAngle(self, target.?);
    self.base.vel = zi.types.fromAngle(angle).mulf(self.entity.mover.speed);

    engine.baseUpdate(self);

    // Are we close to the target or has the distance actually increased?
    // . Set new target
    const cur_distance = engine.entityDist(self, target.?);
    if ((cur_distance > prev_distance or cur_distance < 0.5)) {
        self.base.pos = target.?.base.pos.add(target.?.base.size.mulf(0.5)).sub(self.base.size.mulf(0.5));
        self.entity.mover.current_target = (self.entity.mover.current_target + 1) % self.entity.mover.targets.items.len;
    }
}

pub const vtab: zi.EntityVtab(Entity) = .{
    .load = load,
    .init = init,
    .settings = settings,
    .update = update,
};
