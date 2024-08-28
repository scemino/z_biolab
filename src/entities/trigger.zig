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
    self.entity.trigger.targets = zi.entity.entitiesFromJsonNames(s.get("target").?.object);
    self.size.x = @as(f32, @floatFromInt(s.get("size").?.object.get("x").?.integer));
    self.size.y = @as(f32, @floatFromInt(s.get("size").?.object.get("y").?.integer));
    self.entity.trigger.delay = if (s.get("delay")) |delay| @as(f32, @floatFromInt(delay.integer)) else -1.0;
    self.entity.trigger.can_fire = true;

    if (s.get("checks")) |c| {
        const checks = c.string;
        if (std.mem.indexOf(u8, checks, "player") != null) {
            self.check_against |= zi.entity.ENTITY_GROUP_PLAYER;
        }
        if (std.mem.indexOf(u8, checks, "npc") != null) {
            self.check_against |= zi.entity.ENTITY_GROUP_NPC;
        }
        if (std.mem.indexOf(u8, checks, "enemy") != null) {
            self.check_against |= zi.entity.ENTITY_GROUP_ENEMY;
        }
        if (std.mem.indexOf(u8, checks, "item") != null) {
            self.check_against |= zi.entity.ENTITY_GROUP_ITEM;
        }
        if (std.mem.indexOf(u8, checks, "projectile") != null) {
            self.check_against |= zi.entity.ENTITY_GROUP_PROJECTILE;
        }
        if (std.mem.indexOf(u8, checks, "breakable") != null) {
            self.check_against |= zi.entity.ENTITY_GROUP_BREAKABLE;
        }
    } else {
        self.check_against = zi.entity.ENTITY_GROUP_PLAYER;
    }
}

fn update(self: *Entity) void {
    self.entity.trigger.delay_time -= @as(f32, @floatCast(zi.engine.tick));
}

fn touch(self: *Entity, other: *Entity) void {
    if (!self.entity.trigger.can_fire or self.entity.trigger.delay_time > 0) {
        return;
    }

    for (self.entity.trigger.targets.entities) |e| {
        if (zi.entity.entityByRef(e)) |target| {
            zi.entity.entityTrigger(target, other);
        }
    }

    if (self.entity.trigger.delay == -1) {
        self.entity.trigger.can_fire = false;
    } else {
        self.entity.trigger.delay_time = self.entity.trigger.delay;
    }
}

pub const vtab: zi.EntityVtab = .{
    .settings = settings,
    .update = update,
    .touch = touch,
};
