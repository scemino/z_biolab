const std = @import("std");
const zi = @import("zimpact");
const game = @import("../game.zig");
const Entity = game.Entity;
const vec2 = zi.vec2;
const engine = zi.Engine(game.Entity);

fn settings(self: *Entity, s: std.json.ObjectMap) void {
    self.entity.hurt.damage = @floatFromInt(s.get("damage").?.integer);
    if (self.entity.hurt.damage == 0) {
        self.entity.hurt.damage = 10;
    }
}

fn trigger(self: *Entity, other: *Entity) void {
    engine.entityDamage(other, self, self.entity.hurt.damage);
}

pub const vtab: zi.EntityVtab(Entity) = .{
    .settings = settings,
    .trigger = trigger,
};
