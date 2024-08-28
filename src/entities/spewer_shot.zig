// EDITOR_IGNORE(true)

const std = @import("std");
const zi = @import("zimpact");
const game = @import("../game.zig");
const sgame = @import("../scenes/game.zig");
const g = @import("../global.zig");
const Entity = zi.Entity;
const EntityVtab = zi.EntityVtab;
const Image = zi.Image;
const Anim = zi.Anim;
const AnimDef = zi.AnimDef;
const vec2i = zi.vec2i;
const vec2 = zi.vec2;
const Vec2 = zi.Vec2;
const animDef = zi.animDef;
const Engine = zi.Engine;
const engine = zi.Engine;

var anim_idle: AnimDef = undefined;
var sound_gib: *zi.sound.SoundSource = undefined;

fn load() void {
    const sheet = zi.image("assets/sprites/spewer.qoi");

    anim_idle = zi.animDef(sheet, vec2i(4, 4), 5.0, &[_]u16{16}, true);
}

fn init(self: *Entity) void {
    self.check_against = zi.entity.ENTITY_GROUP_PLAYER;
    self.size = vec2(4, 4);
    self.friction = vec2(1, 0);
    self.anim = zi.anim(&anim_idle);
    self.restitution = 0.7;
    self.physics = zi.entity.ENTITY_PHYSICS_LITE;
    self.check_against = zi.entity.ENTITY_GROUP_PLAYER;

    const player = zi.entity.entityByRef(g.player);
    const dir: f32 = if (self.pos.x - player.?.pos.x > 0) -1 else 1;
    self.vel.x = zi.utils.randFloat(40, 120) * dir;
    self.vel.y = -100;
}

fn collide(self: *Entity, _: Vec2, _: ?zi.Trace) void {
    self.entity.spewer_shot.bounce_count += 1;
    if (self.entity.spewer_shot.bounce_count >= 3) {
        zi.entity.entityKill(self);
    }
}

fn touch(self: *Entity, other: *Entity) void {
    zi.entity.entityDamage(other, self, 10);
    zi.entity.entityKill(self);
}

pub const vtab: zi.EntityVtab = .{
    .load = load,
    .init = init,
    .collide = collide,
    .touch = touch,
};
