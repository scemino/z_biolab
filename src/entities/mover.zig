// EDITOR_SIZE(24, 8);
// EDITOR_RESIZE(false);
// EDITOR_COLOR(81, 132, 188);

const std = @import("std");
const zi = @import("zimpact");
const game = @import("../game.zig");
const Entity = zi.Entity;
const vec2 = zi.vec2;
const vec2i = zi.vec2i;
const engine = zi.Engine;

var anim_idle: zi.AnimDef = undefined;

fn load() void {
    const sheet = zi.image("assets/sprites/elevator.qoi");

    anim_idle = zi.animDef(sheet, vec2i(24, 8), 1.0, &[_]u16{0}, true);
}

fn init(self: *Entity) void {
    self.anim = zi.anim(&anim_idle);
    self.size = vec2(24, 8);
    self.physics = zi.entity.ENTITY_PHYSICS_FIXED;
    self.gravity = 0;
    self.entity.mover.speed = 20;
}

fn settings(self: *Entity, s: std.json.ObjectMap) void {
    self.entity.mover.targets = zi.entity.entitiesFromJsonNames(s.get("target").?.object);
    self.entity.mover.speed = zi.utils.jsonFloat(s.get("speed"));
    if (self.entity.mover.speed == 0) {
        self.entity.mover.speed = 20;
    }
}

fn update(self: *Entity) void {
    if (self.entity.mover.targets.entities.len == 0) {
        return;
    }

    const target = zi.entity.entityByRef(self.entity.mover.targets.entities[@intCast(self.entity.mover.current_target)]);

    const prev_distance = zi.entity.entityDist(self, target.?);
    const angle = zi.entity.entityAngle(self, target.?);
    self.vel = zi.types.fromAngle(angle).mulf(self.entity.mover.speed);

    zi.entity.entityBaseUpdate(self);

    // Are we close to the target or has the distance actually increased?
    // . Set new target
    const cur_distance = zi.entity.entityDist(self, target.?);
    if ((cur_distance > prev_distance or cur_distance < 0.5)) {
        self.pos = target.?.pos.add(target.?.size.mulf(0.5)).sub(self.size.mulf(0.5));
        self.entity.mover.current_target = @intCast((@as(usize, @intCast(self.entity.mover.current_target + 1))) % self.entity.mover.targets.entities.len);
    }
}

pub const vtab: zi.EntityVtab = .{
    .load = load,
    .init = init,
    .settings = settings,
    .update = update,
};
