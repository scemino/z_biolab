// EDITOR_SIZE(10, 13);
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
const Engine = zi.Engine;
const engine = zi.Engine;

var anim_idle: AnimDef = undefined;
var anim_walk: AnimDef = undefined;
var anim_shoot: AnimDef = undefined;
var anim_hit: AnimDef = undefined;
var anim_gib: AnimDef = undefined;
var anim_gun: AnimDef = undefined;
var anim_shot_idle: AnimDef = undefined;
var anim_shot_hit: AnimDef = undefined;
var sound_gib: *zi.sound.SoundSource = undefined;
var sound_shoot: *zi.sound.SoundSource = undefined;

fn load() void {
    const sheet = zi.image("assets/sprites/grunt.qoi");

    anim_idle = zi.animDef(sheet, vec2i(16, 16), 0.5, &[_]u16{ 0, 0, 0, 0, 1, 0, 0, 0, 1, 1, 1 }, true);
    anim_walk = zi.animDef(sheet, vec2i(16, 16), 0.1, &[_]u16{ 6, 7, 8, 9, 10, 11 }, true);
    anim_shoot = zi.animDef(sheet, vec2i(16, 16), 0.2, &[_]u16{2}, true);
    anim_hit = zi.animDef(sheet, vec2i(16, 16), 0.1, &[_]u16{3}, true);

    anim_gib = zi.animDef(sheet, vec2i(4, 4), 5.0, &[_]u16{ 16, 17, 40, 41 }, true);
    anim_gun = zi.animDef(sheet, vec2i(8, 8), 1.0, &[_]u16{11}, true);

    const projectile_sheet = zi.image("assets/sprites/grunt-projectile.qoi");
    anim_shot_idle = zi.animDef(projectile_sheet, vec2i(8, 8), 1.0, &[_]u16{0}, true);
    anim_shot_hit = zi.animDef(projectile_sheet, vec2i(8, 8), 0.1, &[_]u16{ 0, 1, 2, 3, 4, 5 }, true);

    sound_gib = zi.sound.source("assets/sounds/drygib.qoa");
    sound_shoot = zi.sound.source("assets/sounds/grunt-plasma.qoa");
}

fn init(self: *Entity) void {
    self.group = zi.entity.ENTITY_GROUP_ENEMY;
    self.check_against = zi.entity.ENTITY_GROUP_PLAYER;
    self.size = vec2(10, 13);
    self.offset = vec2(3, 3);
    self.friction = vec2(6, 0);
    self.health = 20;
    self.anim = zi.anim(&anim_idle);
    self.entity.grunt.flip = zi.utils.randInt(0, 1) > 0;
    self.physics = zi.entity.ENTITY_PHYSICS_PASSIVE;
}

fn update(self: *Entity) void {
    const player = zi.entity.entityByRef(g.player);
    const player_dist = player.?.pos.sub(self.pos).abs();
    const player_dir: f32 = if (player.?.pos.x - self.pos.x < 0) -1 else 1;

    self.entity.grunt.shoot_time -= @as(f32, @floatCast(zi.engine.tick));
    if (!self.entity.grunt.seen_player) {
        if (player_dist.x < 160 and player_dist.y < 32) {
            self.entity.grunt.seen_player = true;
            self.entity.grunt.shoot_time = 1.5;
        }
    } else if (self.on_ground and self.anim.def != &anim_hit) {
        if ((player_dist.x > 160 or (player_dist.x > 96 and self.anim.def == &anim_walk)) and
            self.entity.grunt.shoot_time < 0)
        {
            if (self.anim.def != &anim_walk) {
                self.anim = zi.anim(&anim_walk);
            }
            self.vel.x = 30 * player_dir;
        } else if (self.anim.def == &anim_walk) {
            self.anim = zi.anim(&anim_idle);
            self.vel.x = 0;
            self.entity.grunt.shoot_time = 1.0;
        } else if (player_dist.y < 64 and self.entity.grunt.shoot_time < 0) {
            const plasma_pos = vec2(self.pos.x + @as(f32, if (self.entity.grunt.flip) -3.0 else 5.0), self.pos.y + 6.0);

            if (zi.entity.entitySpawn(.projectile, plasma_pos)) |plasma| {
                plasma.check_against = zi.entity.ENTITY_GROUP_PLAYER | zi.entity.ENTITY_GROUP_BREAKABLE;
                plasma.anim = zi.anim(&anim_shot_idle);
                plasma.entity.projectile.flip = self.entity.grunt.flip;
                plasma.anim.flip_x = self.entity.grunt.flip;
                plasma.entity.projectile.anim_hit = &anim_shot_hit;
                plasma.vel = vec2(if (self.entity.grunt.flip) -120.0 else 120, 0);
            }

            zi.sound.play(sound_shoot);
            self.entity.grunt.shoot_time = 2.0;

            if (self.anim.def != &anim_idle) {
                self.anim = zi.anim(&anim_idle);
            }
        }

        if (self.anim.def == &anim_idle and self.entity.grunt.shoot_time < 0.5) {
            self.anim = zi.anim(&anim_shoot);
        }

        self.entity.grunt.flip = (player_dir < 0);
    }

    if (self.anim.def == &anim_hit and self.anim.looped() > 0) {
        self.anim = zi.anim(&anim_idle);
    }

    zi.entity.entityBaseUpdate(self);

    self.anim.flip_x = self.entity.grunt.flip;
    self.anim.tile_offset = if (self.entity.grunt.flip) 12 else 0;
}

fn damage(self: *Entity, other: *Entity, value: f32) void {
    self.anim = zi.anim(&anim_hit);
    self.vel.x = if (other.vel.x > 0) 60 else -60;
    if (self.entity.grunt.shoot_time > -0.3) {
        self.entity.grunt.shoot_time = 0.7;
    }
    self.entity.grunt.seen_player = true;

    const gib_count: usize = if (self.health <= value) 10 else 3;
    for (0..gib_count) |_| {
        _ = sgame.spawnParticle(self.pos, 120, 30, other.vel.toAngle(), std.math.pi / 4.0, &anim_gib);
    }

    if (self.health <= value) {
        _ = sgame.spawnParticle(self.pos, 60, 10, other.vel.toAngle(), std.math.pi / 4.0, &anim_gun);
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
