const std = @import("std");
const zi = @import("zimpact");
const game = @import("../game.zig");
const sgame = @import("../scenes/game.zig");
const g = @import("../global.zig");
const Entity = game.Entity;
const EntityVtab = zi.EntityVtab;
const Image = zi.Image;
const Anim = zi.Anim;
const AnimDef = zi.AnimDef;
const vec2i = zi.vec2i;
const vec2 = zi.vec2;
const Vec2 = zi.Vec2;
const animDef = zi.animDef;
const Engine = zi.Engine;
const engine = Engine(game.Entity);

var anim_idle: AnimDef = undefined;
var sound_gib: *zi.sound.SoundSource = undefined;

fn load() void {
    const sheet = zi.image("assets/sprites/spewer.qoi");

    anim_idle = zi.animDef(sheet, vec2i(4, 4), 5.0, &[_]u16{16}, true);
}

fn init(self: *Entity) void {
    self.base.check_against = zi.entity.ENTITY_GROUP_PLAYER;
    self.base.size = vec2(4, 4);
    self.base.friction = vec2(1, 0);
    self.base.anim = zi.anim(&anim_idle);
    self.base.restitution = 0.7;
    self.base.physics = zi.entity.ENTITY_PHYSICS_LITE;
    self.base.check_against = zi.entity.ENTITY_GROUP_PLAYER;

    const player = engine.entityByRef(g.player);
    const dir: f32 = if (self.base.pos.x - player.?.base.pos.x > 0) -1 else 1;
    self.base.vel.x = zi.utils.randFloat(40, 120) * dir;
    self.base.vel.y = -100;
}

fn collide(self: *Entity, _: Vec2, _: ?zi.Trace) void {
    self.entity.spewer_shot.bounce_count += 1;
    if (self.entity.spewer_shot.bounce_count >= 3) {
        engine.entityKill(self);
    }
}

fn touch(self: *Entity, other: *Entity) void {
    engine.entityDamage(other, self, 10);
    engine.entityKill(self);
}

pub const vtab: EntityVtab(Entity) = .{
    .load = load,
    .init = init,
    .collide = collide,
    .touch = touch,
};
