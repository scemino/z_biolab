const std = @import("std");
const zi = @import("zimpact");
const game = @import("../game.zig");
const Entity = game.Entity;
const vec2 = zi.vec2;
const engine = zi.Engine(game.Entity, game.EntityKind);

fn settings(self: *Entity, s: std.json.ObjectMap) void {
    self.entity.trigger.targets = engine.entitiesFromJsonNames(s.get("target").?.object);
    self.base.size.x = @as(f32, @floatFromInt(s.get("size").?.object.get("x").?.integer));
    self.base.size.y = @as(f32, @floatFromInt(s.get("size").?.object.get("y").?.integer));
    self.entity.trigger.delay = if (s.get("delay")) |delay| @as(f32, @floatFromInt(delay.integer)) else -1.0;
    self.entity.trigger.can_fire = true;

    if (s.get("checks")) |c| {
        const checks = c.string;
        if (std.mem.indexOf(u8, checks, "player") != null) {
            self.base.check_against |= zi.entity.ENTITY_GROUP_PLAYER;
        }
        if (std.mem.indexOf(u8, checks, "npc") != null) {
            self.base.check_against |= zi.entity.ENTITY_GROUP_NPC;
        }
        if (std.mem.indexOf(u8, checks, "enemy") != null) {
            self.base.check_against |= zi.entity.ENTITY_GROUP_ENEMY;
        }
        if (std.mem.indexOf(u8, checks, "item") != null) {
            self.base.check_against |= zi.entity.ENTITY_GROUP_ITEM;
        }
        if (std.mem.indexOf(u8, checks, "projectile") != null) {
            self.base.check_against |= zi.entity.ENTITY_GROUP_PROJECTILE;
        }
        if (std.mem.indexOf(u8, checks, "breakable") != null) {
            self.base.check_against |= zi.entity.ENTITY_GROUP_BREAKABLE;
        }
    } else {
        self.base.check_against = zi.entity.ENTITY_GROUP_PLAYER;
    }
}

fn update(self: *Entity) void {
    self.entity.trigger.delay_time -= @as(f32, @floatCast(zi.engine.tick));
}

fn touch(self: *Entity, other: *Entity) void {
    if (!self.entity.trigger.can_fire or self.entity.trigger.delay_time > 0) {
        return;
    }

    for (self.entity.trigger.targets.items) |e| {
        if (engine.entityByRef(e)) |target| {
            engine.entityTrigger(target, other);
        }
    }

    if (self.entity.trigger.delay == -1) {
        self.entity.trigger.can_fire = false;
    } else {
        self.entity.trigger.delay_time = self.entity.trigger.delay;
    }
}

pub var vtab: zi.EntityVtab(Entity) = .{
    .settings = settings,
    .update = update,
    .touch = touch,
};
