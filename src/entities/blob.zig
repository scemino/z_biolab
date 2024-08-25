const std = @import("std");
const zi = @import("zimpact");
const game = @import("../game.zig");
const sgame = @import("../scenes/game.zig");
const g = @import("../global.zig");
const Image = zi.Image;
const Anim = zi.Anim;
const AnimDef = zi.AnimDef;
const Entity = zi.Entity;
const vec2i = zi.vec2i;
const vec2 = zi.vec2;
const Vec2 = zi.Vec2;
const animDef = zi.animDef;

var anim_idle: AnimDef = undefined;
var anim_crawl: AnimDef = undefined;
var anim_jump: AnimDef = undefined;
var anim_hit: AnimDef = undefined;
var anim_gib: AnimDef = undefined;
var sound_gib: *zi.sound.SoundSource = undefined;

fn load() void {
    const sheet = zi.image("assets/sprites/blob.qoi");

    anim_idle = animDef(sheet, vec2i(16, 16), 0.5, &[_]u16{ 1, 2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2 }, true);
    anim_crawl = animDef(sheet, vec2i(16, 16), 0.1, &[_]u16{ 0, 1 }, true);
    anim_jump = animDef(sheet, vec2i(16, 16), 0.2, &[_]u16{ 2, 3, 4 }, true);
    anim_hit = animDef(sheet, vec2i(16, 16), 0.1, &[_]u16{5}, true);

    const gib_sheet = zi.image("assets/sprites/blob-gibs.qoi");
    anim_gib = animDef(gib_sheet, vec2i(4, 4), 10, &[_]u16{ 0, 1, 2 }, true);

    sound_gib = zi.sound.source("assets/sounds/wetgib.qoa");
}

fn init(self: *Entity) void {
    self.group = zi.entity.ENTITY_GROUP_ENEMY;
    self.check_against = zi.entity.ENTITY_GROUP_PLAYER;
    self.size = vec2(10, 13);
    self.offset = vec2(3, 3);
    self.health = 20;
    self.anim = zi.anim(&anim_idle);
    self.anim.gotoRand();
    self.anim.flip_x = zi.utils.randInt(0, 1) > 0;
    self.physics = zi.entity.ENTITY_PHYSICS_PASSIVE;
}

fn update(self: *Entity) void {
    const player = zi.entity.entityByRef(g.player);
    if (player == null) return;

    const player_dist = player.?.pos.sub(self.pos).abs();
    const player_dir: f32 = if (player.?.pos.x - self.pos.x < 0) -1.0 else 1.0;

    if (!self.entity.blob.seen_player) {
        if (player_dist.x < 64 and player_dist.y < 20) {
            self.entity.blob.seen_player = true;
        }
    } else if (self.on_ground and self.anim.def != &anim_hit) {
        self.entity.blob.jump_timer += @as(f32, @floatCast(zi.engine.tick));
        // Init jump
        if (self.anim.def != &anim_jump and self.entity.blob.jump_timer > 0.5 and ((player_dist.x < 40 and player_dist.y > 20) or // near player
            zi.engine.collision_map.?.tileAtPx(self.pos.add(vec2(self.size.x * player_dir, self.size.y))) == 1 // or blocked by wall
        )) {
            self.anim = zi.anim(&anim_jump);
            self.anim.flip_x = (player_dir < 0);
            self.vel.x = 0;
        }

        // Jump
        else if (self.anim.def == &anim_jump and self.anim.looped() > 0) {
            self.vel.y = -70;
            self.vel.x = if (self.anim.flip_x) -60.0 else 60.0;
            self.entity.blob.in_jump = true;
        }

        // Crawl
        else if (self.anim.def != &anim_jump and self.entity.blob.jump_timer > 0.2) {
            self.anim = zi.anim(&anim_crawl);
            self.anim.flip_x = (player_dir < 0);
            self.vel.x = 20 * player_dir;
        }
    }

    if (self.anim.def == &anim_hit and self.anim.looped() > 0) {
        self.anim = zi.anim(&anim_idle);
    }

    if (self.entity.blob.in_jump and self.vel.x == 0 and self.anim.def != &anim_hit) {
        self.vel.x = if (self.anim.flip_x) -30.0 else 30.0;
    }

    const was_on_ground = self.on_ground;

    zi.entity.entityBaseUpdate(self);

    // Just landed?
    if (self.on_ground and !was_on_ground and self.anim.def != &anim_hit) {
        self.entity.blob.in_jump = false;
        self.entity.blob.jump_timer = 0;
        const flip_x = self.anim.flip_x;
        self.anim = zi.anim(&anim_idle);
        self.anim.flip_x = flip_x;
        self.vel.x = 0;
    }
}

pub fn damage(self: *Entity, other: *Entity, value: f32) void {
    // const flip_x = self.anim.flip_x;
    self.anim = zi.anim(&anim_hit);
    self.entity.blob.seen_player = true;
    self.entity.blob.in_jump = false;
    self.vel.x = if (other.vel.x > 0) 50 else -50;

    const gib_count: usize = if (self.health <= value) 30 else 5;
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
