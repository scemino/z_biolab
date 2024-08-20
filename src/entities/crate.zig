const std = @import("std");
const zi = @import("zimpact");
const game = @import("../game.zig");
const sgame = @import("../scenes/game.zig");
const Entity = game.Entity;
const vec2 = zi.vec2;
const vec2i = zi.vec2i;
const engine = zi.Engine(game.Entity);

var anim_idle: zi.AnimDef = undefined;
var anim_debris: zi.AnimDef = undefined;
var sound_crack: *zi.sound.SoundSource = undefined;

fn load() void {
    const sheet = zi.image("assets/sprites/crate.qoi");

    anim_idle = zi.animDef(sheet, vec2i(8, 8), 1.0, &[_]u16{0}, true);
    anim_debris = zi.animDef(sheet, vec2i(4, 4), 5.0, &[_]u16{ 2, 3, 6, 7 }, true);

    sound_crack = zi.sound.source("assets/sounds/crack.qoa");
}

fn init(self: *Entity) void {
    self.base.anim = zi.anim(&anim_idle);
    self.base.size = vec2(8, 8);
    self.base.friction = vec2(4, 0);
    self.base.health = 5;
    self.base.restitution = 0.4;
    self.base.mass = 0.25;

    self.base.group = zi.entity.ENTITY_GROUP_BREAKABLE;
    self.base.check_against = zi.entity.ENTITY_GROUP_NONE;
    self.base.physics = zi.entity.ENTITY_PHYSICS_ACTIVE;
}

fn kill(self: *Entity) void {
    zi.sound.play(sound_crack);

    for (0..10) |_| {
        _ = sgame.spawnParticle(self.base.pos, 120, 30, 0, std.math.pi, &anim_debris);
    }
}

pub const vtab: zi.EntityVtab(Entity) = .{
    .load = load,
    .init = init,
    .kill = kill,
};
