const std = @import("std");
const zi = @import("zimpact");
const game = @import("../game.zig");
const sgame = @import("../scenes/game.zig");
const Entity = zi.Entity;
const vec2 = zi.vec2;
const vec2i = zi.vec2i;
const engine = zi.Engine;

var anim_idle: zi.AnimDef = undefined;
var anim_gib: zi.AnimDef = undefined;
var sound_explode: *zi.sound.SoundSource = undefined;

fn load() void {
    const sheet = zi.image("assets/sprites/mine.qoi");
    anim_idle = zi.animDef(sheet, vec2i(16, 8), 0.17, &[_]u16{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 3 }, true);
    anim_gib = zi.animDef(sheet, vec2i(4, 4), 1, &[_]u16{0}, true);
    sound_explode = zi.sound.source("assets/sounds/mine.qoa");
}

fn init(self: *Entity) void {
    self.size = vec2(8, 5);
    self.offset = vec2(4, 3);
    self.check_against = zi.entity.ENTITY_GROUP_PLAYER;
    self.anim = zi.anim(&anim_idle);
    self.anim.gotoRand();
}

fn kill(self: *Entity) void {
    for (0..10) |_| {
        if (sgame.spawnParticle(self.pos, 120, 30, @as(f32, -std.math.pi / 2.0), @as(f32, std.math.pi / 2.0), &anim_gib)) |particle| {
            particle.physics = zi.entity.ENTITY_PHYSICS_WORLD;
        }
    }
    zi.sound.play(sound_explode);
}

fn touch(self: *Entity, other: *Entity) void {
    zi.entity.entityKill(self);
    zi.entity.entityDamage(other, self, 10);
}

pub const vtab: zi.EntityVtab = .{
    .init = init,
    .load = load,
    .kill = kill,
    .touch = touch,
};
