// EDITOR_SIZE(8, 8);
// EDITOR_RESIZE(true);
// EDITOR_COLOR(255, 229, 14);

const std = @import("std");
const zi = @import("zimpact");
const game = @import("../game.zig");
const Entity = zi.Entity;
const vec2 = zi.vec2;
const engine = zi.Engine;

fn settings(self: *Entity, s: std.json.ObjectMap) void {
    self.entity.hurt.damage = @floatFromInt(s.get("damage").?.integer);
    if (self.entity.hurt.damage == 0) {
        self.entity.hurt.damage = 10;
    }
}

fn trigger(self: *Entity, other: *Entity) void {
    zi.entity.entityDamage(other, self, self.entity.hurt.damage);
}

pub const vtab: zi.EntityVtab = .{
    .settings = settings,
    .trigger = trigger,
};
