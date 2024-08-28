// EDITOR_SIZE(40, 32);
// EDITOR_RESIZE(false);
// EDITOR_COLOR(81, 132, 188);

const std = @import("std");
const zi = @import("zimpact");
const game = @import("../game.zig");
const g = @import("../global.zig");
const sgame = @import("../scenes/game.zig");
const Entity = zi.Entity;
const vec2 = zi.vec2;
const vec2i = zi.vec2i;
const engine = zi.Engine;

var anim_idle: zi.AnimDef = undefined;
var anim_shards: zi.AnimDef = undefined;
var sound_impact: *zi.sound.SoundSource = undefined;
var sound_shatter: *zi.sound.SoundSource = undefined;

fn load() void {
    const sheet = zi.image("assets/sprites/glass-dome.qoi");

    anim_idle = zi.animDef(sheet, vec2i(40, 32), 1.0, &[_]u16{0}, true);

    const sheet_shards = zi.image("assets/sprites/glass-shards.qoi");
    anim_shards = zi.animDef(sheet_shards, vec2i(4, 4), 5.0, &[_]u16{ 0, 1, 2, 3 }, true);

    sound_impact = zi.sound.source("assets/sounds/glass-impact.qoa");
    sound_shatter = zi.sound.source("assets/sounds/glass-shatter.qoa");
}

fn init(self: *Entity) void {
    self.anim = zi.anim(&anim_idle);
    self.size = vec2(40, 32);
    self.health = 80;

    self.group = zi.entity.ENTITY_GROUP_BREAKABLE;
    self.check_against = zi.entity.ENTITY_GROUP_NONE;
    self.physics = zi.entity.ENTITY_PHYSICS_FIXED;
}

fn damage(self: *Entity, other: *Entity, value: f32) void {
    zi.sound.play(sound_impact);

    for (0..3) |_| {
        _ = sgame.spawnParticle(other.pos, 120, 30, 0, std.math.pi, &anim_shards);
    }
    zi.entity.entityBaseDamage(self, other, value);
}

fn kill(self: *Entity) void {
    zi.sound.play(sound_shatter);
    for (0..100) |_| {
        const spawn_pos = vec2(zi.utils.randFloat(self.pos.x, self.pos.x + self.size.x), zi.utils.randFloat(self.pos.y, self.pos.y + self.size.y));
        _ = sgame.spawnParticle(spawn_pos, 120, 30, 0, std.math.pi, &anim_shards);
    }
}

pub const vtab: zi.EntityVtab = .{
    .load = load,
    .init = init,
    .damage = damage,
    .kill = kill,
};
