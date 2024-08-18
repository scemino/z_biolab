const std = @import("std");
const zi = @import("zimpact");
const game = @import("../game.zig");
const sgame = @import("../scenes/game.zig");
const Entity = game.Entity;
const vec2 = zi.vec2;
const vec2i = zi.vec2i;
const engine = zi.Engine(game.Entity, game.EntityKind);

var anim_idle: zi.AnimDef = undefined;

fn load() void {
    const sheet = zi.image("assets/sprites/debris.qoi");
    anim_idle = zi.animDef(sheet, vec2i(4, 4), 5.0, &[_]u16{ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14 }, true);
}

fn settings(self: *Entity, s: std.json.ObjectMap) void {
    self.entity.debris.count = @intCast(s.get("count").?.integer);
    self.entity.debris.duration = zi.utils.jsonFloat(s.get("duration"));
    self.base.size.x = zi.utils.jsonFloat(s.get("size").?.object.get("x"));
    self.base.size.y = zi.utils.jsonFloat(s.get("size").?.object.get("y"));
}

fn trigger(self: *Entity, _: *Entity) void {
    self.entity.debris.duration_time = self.entity.debris.duration;
}

fn update(self: *Entity) void {
    if (self.entity.debris.duration_time <= 0) {
        return;
    }

    self.entity.debris.emit_time -= @as(f32, @floatCast(zi.engine.tick));
    self.entity.debris.duration_time -= @as(f32, @floatCast(zi.engine.tick));
    if (self.entity.debris.emit_time < 0) {
        self.entity.debris.emit_time = self.entity.debris.duration / @as(f32, @floatFromInt(self.entity.debris.count));

        const spawn_pos = vec2(zi.utils.randFloat(self.base.pos.x, self.base.pos.x + self.base.size.x), zi.utils.randFloat(self.base.pos.y, self.base.pos.y + self.base.size.y));
        if (sgame.spawnParticle(spawn_pos, 30, 10, 0, std.math.pi, &anim_idle)) |particle| {
            particle.entity.particle.life_time = 2;
            particle.entity.particle.fade_time = 1;
            particle.base.restitution = 0.6;
        }
    }
}

pub var vtab: zi.EntityVtab(Entity) = .{
    .load = load,
    .settings = settings,
    .trigger = trigger,
    .update = update,
};
