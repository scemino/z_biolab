const std = @import("std");
const zi = @import("zimpact");
const game = @import("../game.zig");
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

fn load() void {}

fn init(self: *Entity) void {
    self.size = vec2(6, 3);
    self.offset = vec2(1, 2);
    self.gravity = 0;
    self.physics = zi.entity.ENTITY_PHYSICS_WORLD;
}

fn setHit(self: *Entity) void {
    self.entity.projectile.has_hit = true;
    self.vel.x = 0;

    self.anim = zi.anim(self.entity.projectile.anim_hit);
    self.anim.flip_x = self.entity.projectile.flip;
}

fn update(self: *Entity) void {
    zi.entity.entityBaseUpdate(self);

    if (self.entity.projectile.has_hit and self.anim.looped() > 0) {
        zi.entity.entityKill(self);
    }
}

fn collide(self: *Entity, _: Vec2, _: ?zi.Trace) void {
    if (self.entity.projectile.has_hit) {
        return;
    }
    setHit(self);
}

fn touch(self: *Entity, other: *Entity) void {
    if (self.entity.projectile.has_hit) {
        return;
    }
    zi.entity.entityDamage(other, self, 10);
    setHit(self);
}

pub const vtab: zi.EntityVtab = .{
    .init = init,
    .update = update,
    .collide = collide,
    .touch = touch,
};
