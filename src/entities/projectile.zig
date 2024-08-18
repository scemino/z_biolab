const std = @import("std");
const zi = @import("zimpact");
const game = @import("../game.zig");
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

fn load() void {}

fn init(self: *Entity) void {
    self.base.size = vec2(6, 3);
    self.base.offset = vec2(1, 2);
    self.base.gravity = 0;
    self.base.physics = zi.entity.ENTITY_PHYSICS_WORLD;
}

fn setHit(self: *Entity) void {
    self.entity.projectile.has_hit = true;
    self.base.vel.x = 0;

    self.base.anim = zi.anim(self.entity.projectile.anim_hit);
    self.base.anim.flip_x = self.entity.projectile.flip;
}

fn update(self: *Entity) void {
    engine.baseUpdate(self);

    if (self.entity.projectile.has_hit and self.base.anim.looped() > 0) {
        engine.entityKill(self);
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
    engine.entityDamage(other, self, 10);
    setHit(self);
}

pub var vtab: EntityVtab(Entity) = .{
    .init = init,
    .update = update,
    .collide = collide,
    .touch = touch,
};
