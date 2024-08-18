const std = @import("std");
const zi = @import("zimpact");
const game = @import("../game.zig");
const sgame = @import("../scenes/game.zig");
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

pub const LEFT: u8 = 1;
pub const RIGHT: u8 = 2;
pub const JUMP: u8 = 3;
pub const SHOOT: u8 = 4;

const JUMP_INITIAL_VEL = 30.0;
const JUMP_HIGH_TIME = 0.14;
const JUMP_HIGH_ACCEL = 780;
const ACCEL_GROUND = 600;
const ACCEL_AIR = 300;
const FRICTION_GROUND = 10;
const FRICTION_AIR = 5;

var anim_idle: AnimDef = undefined;
var anim_scratch: AnimDef = undefined;
var anim_shrug: AnimDef = undefined;
var anim_run: AnimDef = undefined;
var anim_jump: AnimDef = undefined;
var anim_fall: AnimDef = undefined;
var anim_land: AnimDef = undefined;
var anim_die: AnimDef = undefined;
var anim_spawn: AnimDef = undefined;
var anim_gib: AnimDef = undefined;
var anim_gib_gun: AnimDef = undefined;
var anim_plasma_idle: AnimDef = undefined;
var anim_plasma_hit: AnimDef = undefined;
var hints: *Image = undefined;
var sound_bounce: *zi.sound.SoundSource = undefined;
var sound_plasma: *zi.sound.SoundSource = undefined;
var sound_die: *zi.sound.SoundSource = undefined;

fn load() void {
    const sheet = zi.image("assets/sprites/player.qoi");

    anim_idle = animDef(sheet, vec2i(16, 16), 1.0, &[_]u16{0}, true);
    anim_scratch = animDef(sheet, vec2i(16, 16), 0.3, &[_]u16{ 2, 1, 2, 1, 2 }, false);
    anim_shrug = animDef(sheet, vec2i(16, 16), 0.3, &[_]u16{ 3, 3, 3, 3, 3, 3, 4, 3, 3 }, false);
    anim_run = animDef(sheet, vec2i(16, 16), 0.07, &[_]u16{ 6, 7, 8, 9, 10, 11 }, true);
    anim_jump = animDef(sheet, vec2i(16, 16), 1.0, &[_]u16{15}, true);
    anim_fall = animDef(sheet, vec2i(16, 16), 0.4, &[_]u16{ 12, 13 }, true);
    anim_land = animDef(sheet, vec2i(16, 16), 0.15, &[_]u16{14}, true);
    anim_die = animDef(sheet, vec2i(16, 16), 0.07, &[_]u16{ 18, 19, 20, 21, 22, 23, 16, 16, 16 }, true);
    anim_spawn = animDef(sheet, vec2i(16, 16), 0.07, &[_]u16{ 16, 16, 16, 23, 22, 21, 20, 19, 18 }, true);
    anim_gib = animDef(sheet, vec2i(8, 8), 10, &[_]u16{ 82, 94 }, true);
    anim_gib_gun = animDef(sheet, vec2i(8, 8), 10, &[_]u16{11}, true);

    const plasma_sheet = zi.image("assets/sprites/projectile.qoi");
    anim_plasma_idle = animDef(plasma_sheet, vec2i(8, 8), 1.0, &[_]u16{0}, true);
    anim_plasma_hit = animDef(plasma_sheet, vec2i(8, 8), 0.1, &[_]u16{ 0, 1, 2, 3, 4, 5 }, false);

    sound_plasma = zi.sound.source("assets/sounds/plasma.qoa");
    sound_die = zi.sound.source("assets/sounds/die-respawn.qoa");
}

fn init(self: *Entity) void {
    self.base.anim = zi.anim(&anim_spawn);
    self.base.physics = zi.entity.ENTITY_PHYSICS_ACTIVE;
    self.base.offset = vec2(4, 2);
    self.base.size = vec2(8, 14);
    self.base.group = zi.entity.ENTITY_GROUP_PLAYER;
}

fn update(self: *Entity) void {
    // spawning?
    if (self.base.anim.def == &anim_spawn) {
        if (self.base.anim.looped() > 0) {
            self.base.anim = zi.anim(&anim_idle);
        } else {
            return;
        }
    }

    // dying?
    if (self.base.anim.def == &anim_die) {
        if (self.base.anim.looped() > 0) {
            engine.entityKill(self);
        }
        return;
    }

    self.base.friction.x = if (self.base.on_ground) FRICTION_GROUND else FRICTION_AIR;

    var did_move: bool = false;
    if (zi.input.stateb(LEFT)) {
        self.base.accel.x = if (self.base.on_ground) -ACCEL_GROUND else -ACCEL_AIR;
        self.entity.player.flip = true;
        did_move = true;
    } else if (zi.input.stateb(RIGHT)) {
        self.base.accel.x = if (self.base.on_ground) ACCEL_GROUND else ACCEL_AIR;
        self.entity.player.flip = false;
        did_move = true;
    } else {
        self.base.accel.x = 0;
    }

    if (zi.input.stateb(JUMP)) {
        if (self.base.on_ground and self.entity.player.can_jump) {
            self.base.vel.y = -JUMP_INITIAL_VEL;
            self.entity.player.can_jump = false;
            self.entity.player.high_jump_time = JUMP_HIGH_TIME;
        } else if (self.entity.player.high_jump_time > 0) {
            self.entity.player.high_jump_time -= @as(f32, @floatCast(zi.engine.tick));
            const d = self.entity.player.high_jump_time;
            const f = @max(0, if (d < 0) zi.engine.tick + d else zi.engine.tick);
            self.base.vel.y -= @as(f32, @floatCast(JUMP_HIGH_ACCEL * f));
        }
    } else {
        self.entity.player.high_jump_time = 0;
        self.entity.player.can_jump = true;
    }

    if (zi.input.pressed(SHOOT)) {
        const spawn_pos = self.base.pos.add(vec2(if (self.entity.player.flip) -3 else 5, 6));
        if (engine.spawn(.projectile, spawn_pos)) |plasma| {
            plasma.base.vel = vec2(if (self.entity.player.flip) -200 else 200, 0);
            plasma.base.check_against = zi.entity.ENTITY_GROUP_ENEMY | zi.entity.ENTITY_GROUP_BREAKABLE;
            plasma.base.anim = zi.anim(&anim_plasma_idle);
            plasma.entity.projectile.flip = self.entity.player.flip;
            plasma.base.anim.flip_x = self.entity.player.flip;
            plasma.entity.projectile.anim_hit = &anim_plasma_hit;
            zi.sound.play(sound_plasma);
        }
    }

    const was_on_ground = self.base.on_ground;
    engine.baseUpdate(self);

    // Just landed ?
    if (!was_on_ground and self.base.on_ground) {
        self.base.anim = zi.anim(&anim_land);
    }

    // On ground?
    else if (was_on_ground and (self.base.anim.def != &anim_land or self.base.anim.looped() > 0)) {
        if (did_move) {
            if (was_on_ground and self.base.anim.def != &anim_run) {
                self.base.anim = zi.anim(&anim_run);
            }
            self.entity.player.idle_time = 0;
            self.entity.player.is_idle = false;
        } else {
            if (!self.entity.player.is_idle or (!self.base.anim.def.?.loop and self.base.anim.looped() > 0)) {
                self.entity.player.is_idle = true;
                self.entity.player.idle_time = zi.utils.randFloat(3, 7);
                self.base.anim = zi.anim(&anim_idle);
            }
            self.entity.player.idle_time -= @as(f32, @floatCast(zi.engine.tick));
            if (self.entity.player.is_idle and self.entity.player.idle_time < 0) {
                self.entity.player.idle_time = zi.utils.randFloat(3, 7);
                self.base.anim = if (zi.utils.randInt(0, 1) == 0) zi.anim(&anim_scratch) else zi.anim(&anim_shrug);
            }
        }
    }

    // In air?
    else if (!was_on_ground) {
        if (self.base.vel.y < 0) {
            if (self.base.anim.def != &anim_jump) {
                self.base.anim = zi.anim(&anim_jump);
            }
        } else {
            if (self.base.anim.def != &anim_fall) {
                self.base.anim = zi.anim(&anim_fall);
            }
        }
        self.entity.player.is_idle = false;
    }

    self.base.anim.flip_x = self.entity.player.flip;
    self.base.anim.tile_offset = if (self.entity.player.flip) 24 else 0;
}

fn damage(self: *Entity, _: *Entity, _: f32) void {
    if (self.base.anim.def != &anim_die) {
        self.base.anim = zi.anim(&anim_die);
        for (0..5) |_| {
            if (sgame.spawnParticle(self.base.pos, 70, 30, @as(f32, -std.math.pi / 2.0), @as(f32, std.math.pi / 2.0), &anim_gib)) |particle| {
                particle.base.physics = zi.entity.ENTITY_PHYSICS_MOVE;
                particle.entity.particle.life_time = 0.5;
                particle.entity.particle.fade_time = 0.5;
            }
        }

        if (sgame.spawnParticle(self.base.pos, 60, 10, @as(f32, -std.math.pi / 2.0), @as(f32, std.math.pi / 2.0), &anim_gib_gun)) |gun| {
            gun.base.size = vec2(8, 8);
        }

        zi.sound.play(sound_die);
    }
}

fn kill(_: *Entity) void {
    sgame.respawn();
}

pub var vtab: EntityVtab(Entity) = .{
    .load = load,
    .init = init,
    .update = update,
    .damage = damage,
    .kill = kill,
};
