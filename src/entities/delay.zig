const std = @import("std");
const zi = @import("zimpact");
const game = @import("../game.zig");
const Entity = zi.Entity;
const vec2 = zi.vec2;

fn settings(self: *Entity, s: std.json.ObjectMap) void {
    self.entity.delay.targets = zi.entity.entitiesFromJsonNames(s.get("target").?.object);
    self.entity.delay.delay = zi.utils.jsonFloat(s.get("delay"));
}

fn update(self: *Entity) void {
    self.entity.delay.delay_time -= @as(f32, @floatCast(zi.engine.tick));
    if (!self.entity.delay.fire or self.entity.delay.delay_time > 0) {
        return;
    }
    self.entity.delay.fire = false;

    for (self.entity.delay.targets.entities) |e| {
        if (zi.entity.entityByRef(e)) |target| {
            zi.entity.entityTrigger(target, zi.entity.entityByRef(self.entity.delay.triggered_by).?);
        }
    }
}

fn trigger(self: *Entity, other: *Entity) void {
    self.entity.delay.fire = true;
    self.entity.delay.delay_time = self.entity.delay.delay;
    self.entity.delay.triggered_by = zi.entity.entityRef(other);
}

pub const vtab: zi.EntityVtab = .{
    .settings = settings,
    .update = update,
    .trigger = trigger,
};
