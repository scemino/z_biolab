// EDITOR_SIZE(14, 8);
// EDITOR_RESIZE(false);
// EDITOR_COLOR(255, 155, 32);

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

var anim_idle: AnimDef = undefined;
var anim_shoot: AnimDef = undefined;
var anim_hit: AnimDef = undefined;
var anim_shot_idle: AnimDef = undefined;
var anim_shot_hit: AnimDef = undefined;
var anim_gib: AnimDef = undefined;
var sound_gib: *zi.sound.SoundSource = undefined;

fn load() void {
    const sheet = zi.image("assets/sprites/dropper.qoi");

    anim_idle = zi.animDef(sheet, vec2i(16, 8), 1.0, &[_]u16{0}, true);
    anim_shoot = zi.animDef(sheet, vec2i(16, 8), 0.2, &[_]u16{ 1, 2, 2, 1 }, true);
    anim_hit = zi.animDef(sheet, vec2i(16, 8), 0.2, &[_]u16{3}, true);

    anim_shot_idle = zi.animDef(sheet, vec2i(8, 8), 1.0, &[_]u16{8}, true);
    anim_shot_hit = zi.animDef(sheet, vec2i(8, 8), 0.1, &[_]u16{ 9, 10, 11 }, true);

    const gib_sheet = zi.image("assets/sprites/blob-gibs.qoi");
    anim_gib = zi.animDef(gib_sheet, vec2i(4, 4), 10, &[_]u16{ 0, 1, 2 }, true);

    sound_gib = zi.sound.source("assets/sounds/wetgib.qoa");
}

fn init(self: *Entity) void {
    self.anim = zi.anim(&anim_idle);
    self.size = vec2(14, 8);
    self.offset = vec2(1, 0);
    self.group = zi.entity.ENTITY_GROUP_ENEMY;
    self.check_against = zi.entity.ENTITY_GROUP_PLAYER;
    self.health = 80;
    self.entity.dropper.shoot_wait_time = 1;
    self.entity.dropper.shoot_time = 10;
    self.entity.dropper.can_shoot = false;
}

fn update(self: *Entity) void {
    const player = zi.entity.entityByRef(g.player);

    self.entity.dropper.shoot_wait_time -= @as(f32, @floatCast(zi.engine.tick));
    self.entity.dropper.shoot_time -= @as(f32, @floatCast(zi.engine.tick));

    if (self.anim.def == &anim_hit and self.anim.looped() > 0) {
        self.anim.def = &anim_idle;
        self.entity.dropper.shoot_wait_time = 0.5;
    } else if (self.anim.def == &anim_idle and
        self.entity.dropper.shoot_wait_time < 0 and
        self.pos.dist(player.?.pos) < 128)
    {
        self.anim = zi.anim(&anim_shoot);
        self.entity.dropper.shoot_time = 0.8;
        self.entity.dropper.can_shoot = true;
    } else if (self.anim.def == &anim_shoot and
        self.entity.dropper.can_shoot and
        self.entity.dropper.shoot_time < 0)
    {
        self.entity.dropper.can_shoot = false;
        const drop_pos = self.pos.add(vec2(5, 6));
        if (zi.entity.entitySpawn(.projectile, drop_pos)) |drop| {
            drop.size = vec2(4, 4);
            drop.gravity = 1;
            drop.offset = vec2(2, 4);
            drop.check_against = zi.entity.ENTITY_GROUP_PLAYER | zi.entity.ENTITY_GROUP_BREAKABLE;
            drop.anim = zi.anim(&anim_shot_idle);
            drop.entity.projectile.anim_hit = &anim_shot_hit;
            drop.vel = vec2(0, 0);
        }
    }

    if (self.anim.def == &anim_shoot and self.anim.looped() > 0) {
        self.anim = zi.anim(&anim_idle);
        self.entity.dropper.shoot_wait_time = 0.5;
    }

    zi.entity.entityBaseUpdate(self);
}

fn damage(self: *Entity, other: *Entity, value: f32) void {
    self.anim = zi.anim(&anim_hit);
    self.vel.x = if (other.vel.x > 0) 50 else -50;

    const gib_count: usize = if (self.health <= value) 20 else 3;
    for (0..gib_count) |_| {
        _ = sgame.spawnParticle(self.pos, 120, 30, other.vel.toAngle(), std.math.pi / 4.0, &anim_gib);
    }

    zi.sound.play(sound_gib);
    zi.entity.entityBaseDamage(self, other, value);
}

fn touch(self: *Entity, other: *Entity) void {
    zi.entity.entityDamage(other, self, 10);
}

pub const vtab: zi.EntityVtab = .{
    .load = load,
    .init = init,
    .update = update,
    .damage = damage,
    .touch = touch,
};
