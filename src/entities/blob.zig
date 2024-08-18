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
const engine = Engine(game.Entity, game.EntityKind);

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
    self.base.group = zi.entity.ENTITY_GROUP_ENEMY;
    self.base.check_against = zi.entity.ENTITY_GROUP_PLAYER;
    self.base.size = vec2(10, 13);
    self.base.offset = vec2(3, 3);
    self.base.health = 20;
    self.base.anim = zi.anim(&anim_idle);
    self.base.anim.gotoRand();
    self.base.anim.flip_x = zi.utils.randInt(0, 1) > 0;
    self.base.physics = zi.entity.ENTITY_PHYSICS_PASSIVE;
}

fn update(self: *Entity) void {
    const player = engine.entityByRef(g.player);
    if (player == null) return;

    const player_dist = player.?.base.pos.sub(self.base.pos).abs();
    const player_dir: f32 = if (player.?.base.pos.x - self.base.pos.x < 0) -1.0 else 1.0;

    if (!self.entity.blob.seen_player) {
        if (player_dist.x < 64 and player_dist.y < 20) {
            self.entity.blob.seen_player = true;
        }
    } else if (self.base.on_ground and self.base.anim.def != &anim_hit) {
        self.entity.blob.jump_timer += @as(f32, @floatCast(zi.engine.tick));
        // Init jump
        if (self.base.anim.def != &anim_jump and self.entity.blob.jump_timer > 0.5 and ((player_dist.x < 40 and player_dist.y > 20) or // near player
            zi.engine.collision_map.?.tileAtPx(self.base.pos.add(vec2(self.base.size.x * player_dir, self.base.size.y))) == 1 // or blocked by wall
        )) {
            self.base.anim = zi.anim(&anim_jump);
            self.base.anim.flip_x = (player_dir < 0);
            self.base.vel.x = 0;
        }

        // Jump
        else if (self.base.anim.def == &anim_jump and self.base.anim.looped() > 0) {
            self.base.vel.y = -70;
            self.base.vel.x = if (self.base.anim.flip_x) -60.0 else 60.0;
            self.entity.blob.in_jump = true;
        }

        // Crawl
        else if (self.base.anim.def != &anim_jump and self.entity.blob.jump_timer > 0.2) {
            self.base.anim = zi.anim(&anim_crawl);
            self.base.anim.flip_x = (player_dir < 0);
            self.base.vel.x = 20 * player_dir;
        }
    }

    if (self.base.anim.def == &anim_hit and self.base.anim.looped() > 0) {
        self.base.anim = zi.anim(&anim_idle);
    }

    if (self.entity.blob.in_jump and self.base.vel.x == 0 and self.base.anim.def != &anim_hit) {
        self.base.vel.x = if (self.base.anim.flip_x) -30.0 else 30.0;
    }

    const was_on_ground = self.base.on_ground;

    engine.baseUpdate(self);

    // Just landed?
    if (self.base.on_ground and !was_on_ground and self.base.anim.def != &anim_hit) {
        self.entity.blob.in_jump = false;
        self.entity.blob.jump_timer = 0;
        const flip_x = self.base.anim.flip_x;
        self.base.anim = zi.anim(&anim_idle);
        self.base.anim.flip_x = flip_x;
        self.base.vel.x = 0;
    }
}

pub fn damage(self: *Entity, other: *Entity, value: f32) void {
    // const flip_x = self.anim.flip_x;
    self.base.anim = zi.anim(&anim_hit);
    self.entity.blob.seen_player = true;
    self.entity.blob.in_jump = false;
    self.base.vel.x = if (other.base.vel.x > 0) 50 else -50;

    const gib_count: usize = if (self.base.health <= value) 30 else 5;
    for (0..gib_count) |_| {
        _ = sgame.spawnParticle(self.base.pos, 120, 30, other.base.vel.toAngle(), std.math.pi / 4.0, &anim_gib);
    }

    zi.sound.play(sound_gib);
    engine.entityBaseDamage(self, other, value);
}

fn touch(self: *Entity, other: *Entity) void {
    engine.entityDamage(other, self, 10);
}

pub var vtab: EntityVtab(Entity) = .{
    .load = load,
    .init = init,
    .update = update,
    .damage = damage,
    .touch = touch,
};
