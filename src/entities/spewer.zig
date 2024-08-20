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
var anim_spew: AnimDef = undefined;
var anim_hit: AnimDef = undefined;
var anim_gib: AnimDef = undefined;
var sound_gib: *zi.sound.SoundSource = undefined;

fn load() void {
    const sheet = zi.image("assets/sprites/spewer.qoi");

    anim_idle = zi.animDef(sheet, vec2i(16, 8), 0.5, &[_]u16{ 0, 0, 0, 0, 0, 0, 0, 0, 1 }, true);
    anim_spew = zi.animDef(sheet, vec2i(16, 8), 0.1, &[_]u16{ 1, 2, 2, 1, 1 }, true);
    anim_hit = zi.animDef(sheet, vec2i(16, 8), 0.2, &[_]u16{3}, true);
    anim_gib = zi.animDef(sheet, vec2i(4, 4), 1.0, &[_]u16{16}, true);

    sound_gib = zi.sound.source("assets/sounds/drygib.qoa");
}

fn init(self: *Entity) void {
    self.base.group = zi.entity.ENTITY_GROUP_ENEMY;
    self.base.check_against = zi.entity.ENTITY_GROUP_PLAYER;
    self.base.size = vec2(16, 8);
    self.base.offset = vec2(0, 0);
    self.base.health = 20;
    self.base.anim = zi.anim(&anim_idle);
    self.entity.spewer.shoot_wait_time = 1;
    self.entity.spewer.shoot_time = 10;
}

fn update(self: *Entity) void {
    self.entity.spewer.shoot_time -= @as(f32, @floatCast(zi.engine.tick));
    self.entity.spewer.shoot_wait_time -= @as(f32, @floatCast(zi.engine.tick));

    const player = engine.entityByRef(g.player);

    if (self.base.anim.def == &anim_hit and self.base.anim.looped() > 0) {
        self.base.anim = zi.anim(&anim_idle);
        self.entity.spewer.shoot_wait_time = 0.5;
    } else if (self.base.anim.def == &anim_idle and
        self.entity.spewer.shoot_wait_time < 0 and
        player.?.base.pos.dist(self.base.pos) < 80)
    {
        self.base.anim = zi.anim(&anim_spew);
        self.entity.spewer.shoot_time = 0.45;
        self.entity.spewer.can_shoot = true;
    } else if (self.base.anim.def == &anim_spew and
        self.entity.spewer.can_shoot and
        self.entity.spewer.shoot_time < 0)
    {
        self.entity.spewer.can_shoot = false;
        const spew_pos = self.base.pos.add(vec2(4, 4));
        _ = engine.spawn(.spewer_shot, spew_pos);
    }

    if (self.base.anim.def == &anim_spew and self.base.anim.looped() > 0) {
        self.base.anim = zi.anim(&anim_idle);
        self.entity.spewer.shoot_wait_time = 1.5;
    }

    self.base.anim.flip_x = (self.base.pos.x - player.?.base.pos.x < 0);

    engine.baseUpdate(self);
}

fn damage(self: *Entity, other: *Entity, value: f32) void {
    self.base.anim = zi.anim(&anim_hit);

    const gib_count: usize = if (self.base.health <= value) 10 else 3;
    for (0..gib_count) |_| {
        _ = sgame.spawnParticle(engine.entityCenter(self), 120, 30, other.base.vel.toAngle(), std.math.pi / 4.0, &anim_gib);
    }

    zi.sound.play(sound_gib);
    engine.entityBaseDamage(self, other, value);
}

fn touch(self: *Entity, other: *Entity) void {
    engine.entityDamage(other, self, 10);
}

pub const vtab: EntityVtab(Entity) = .{
    .load = load,
    .init = init,
    .update = update,
    .damage = damage,
    .touch = touch,
};
