// EDITOR_SIZE(16, 9);
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

var anim_crawl: AnimDef = undefined;
var anim_shoot: AnimDef = undefined;
var anim_hit: AnimDef = undefined;
var anim_gib: AnimDef = undefined;
var anim_shot_idle: AnimDef = undefined;
var anim_shot_hit: AnimDef = undefined;
var sound_gib: *zi.sound.SoundSource = undefined;

fn load() void {
    const sheet = zi.image("assets/sprites/spike.qoi");

    anim_crawl = zi.animDef(sheet, vec2i(16, 16), 0.08, &[_]u16{ 5, 6, 7 }, true);
    anim_shoot = zi.animDef(sheet, vec2i(16, 16), 0.15, &[_]u16{ 3, 3, 0, 1, 2, 2, 2, 1, 3, 3, 3 }, true);
    anim_hit = zi.animDef(sheet, vec2i(16, 16), 0.1, &[_]u16{8}, true);

    anim_gib = zi.animDef(sheet, vec2i(8, 8), 5.0, &[_]u16{ 28, 29, 38, 39 }, true);

    anim_shot_idle = zi.animDef(sheet, vec2i(8, 8), 0.1, &[_]u16{ 8, 9 }, true);
    anim_shot_hit = zi.animDef(sheet, vec2i(8, 8), 0.1, &[_]u16{ 18, 19 }, true);

    sound_gib = zi.sound.source("assets/sounds/drygib.qoa");
}

fn init(self: *Entity) void {
    self.group = zi.entity.ENTITY_GROUP_ENEMY;
    self.check_against = zi.entity.ENTITY_GROUP_PLAYER;
    self.size = vec2(16, 9);
    self.offset = vec2(0, 7);
    self.health = 30;
    self.anim = zi.anim(&anim_crawl);
    self.physics = zi.entity.ENTITY_PHYSICS_PASSIVE;
    self.entity.spike.shoot_wait_time = 10;
}

fn shoot(pos: Vec2, vel: Vec2) void {
    if (zi.entity.entitySpawn(.projectile, pos)) |spike| {
        spike.size = vec2(4, 4);
        spike.offset = vec2(2, 2);
        spike.check_against = zi.entity.ENTITY_GROUP_PLAYER | zi.entity.ENTITY_GROUP_BREAKABLE;
        spike.anim = zi.anim(&anim_shot_idle);
        spike.entity.projectile.anim_hit = &anim_shot_hit;
        spike.vel = vel;
    }
}

fn update(self: *Entity) void {
    const player = zi.entity.entityByRef(g.player);

    // shooting
    if (self.anim.def == &anim_shoot) {

        // end shooting
        if (self.anim.looped() > 0) {
            self.anim = zi.anim(&anim_crawl);
        }

        // spawn spikes
        self.entity.spike.shoot_time -= @as(f32, @floatCast(zi.engine.tick));
        if (self.entity.spike.can_shoot and self.entity.spike.shoot_time < 0) {
            self.entity.spike.can_shoot = false;
            shoot(self.pos.add(vec2(6, -4)), vec2(0, -60));
            shoot(self.pos.add(vec2(1, -2)), vec2(-60, 0));
            shoot(self.pos.add(vec2(10, -2)), vec2(60, 0));
        }
    }

    // Crawling
    else if (self.anim.def == &anim_crawl) {
        self.entity.spike.shoot_wait_time -= @as(f32, @floatCast(zi.engine.tick));
        // Init shoot
        if (self.entity.spike.shoot_wait_time < 0 and
            player.?.pos.dist(self.pos) < 160)
        {
            self.anim = zi.anim(&anim_shoot);
            self.entity.spike.shoot_wait_time = 5;
            self.entity.spike.shoot_time = 1.2;
            self.entity.spike.can_shoot = true;
            self.vel.x = 0;
        }

        // Crawl on
        else {
            const check_pos = vec2(self.pos.x + if (self.entity.spike.flip) 4 else self.size.x - 4, self.pos.y + self.size.y + 1);

            // Near abyss? return!
            if (zi.engine.collision_map.?.tileAtPx(check_pos) == 0) {
                self.entity.spike.flip = !self.entity.spike.flip;
            }
            self.vel.x = if (self.entity.spike.flip) -14 else 14;
        }
    }

    // Hit anim finished?
    else if (self.anim.def == &anim_hit and self.anim.looped() > 0) {
        self.anim = zi.anim(&anim_crawl);
    }

    _ = zi.entity.entitiesByProximity(game.EntityKind.player, self, 30);

    zi.entity.entityBaseUpdate(self);
}

fn damage(self: *Entity, other: *Entity, value: f32) void {
    self.anim = zi.anim(&anim_hit);
    self.vel.x = if (other.vel.x > 0) 50 else -50;

    const gib_count: usize = if (self.health <= value) 15 else 3;
    for (0..gib_count) |_| {
        if (sgame.spawnParticle(zi.entity.entityCenter(self), 120, 30, other.vel.toAngle(), std.math.pi / 4.0, &anim_gib)) |particle| {
            particle.offset = vec2(2, 2);
        }
    }

    zi.sound.play(sound_gib);
    zi.entity.entityBaseDamage(self, other, value);
}

fn collide(self: *Entity, normal: Vec2, _: ?zi.Trace) void {
    if (normal.x != 0) {
        self.entity.spike.flip = !self.entity.spike.flip;
    }
}

fn touch(self: *Entity, other: *Entity) void {
    zi.entity.entityDamage(other, self, 10);
}

pub const vtab: zi.EntityVtab = .{
    .load = load,
    .init = init,
    .update = update,
    .damage = damage,
    .collide = collide,
    .touch = touch,
};
