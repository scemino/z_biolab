const std = @import("std");
const zi = @import("zimpact");
const game = @import("../game.zig");
const sgame = @import("../scenes/game.zig");
const Entity = game.Entity;
const vec2 = zi.vec2;
const vec2i = zi.vec2i;
const engine = zi.Engine(game.Entity, game.EntityKind);

var anim_idle: zi.AnimDef = undefined;
var anim_activated: zi.AnimDef = undefined;
var anim_respawn: zi.AnimDef = undefined;
var sound_activated: *zi.sound.SoundSource = undefined;

fn load() void {
    const sheet = zi.image("assets/sprites/respawn-pod.qoi");

    anim_idle = zi.animDef(sheet, vec2i(18, 16), 0.5, &[_]u16{ 0, 1 }, true);
    anim_activated = zi.animDef(sheet, vec2i(18, 16), 0.5, &[_]u16{ 2, 3 }, true);
    anim_respawn = zi.animDef(sheet, vec2i(18, 16), 0.3, &[_]u16{ 0, 4 }, true);

    sound_activated = zi.sound.source("assets/sounds/respawn-activate.qoa");
}

fn init(self: *Entity) void {
    self.base.check_against = zi.entity.ENTITY_GROUP_PLAYER;
    self.base.anim = zi.anim(&anim_idle);
    self.base.size = vec2(18, 16);
    self.base.draw_order = -1;
}

fn update(self: *Entity) void {
    if (self.base.anim.def == &anim_respawn and self.base.anim.looped() > 4) {
        self.base.anim = zi.anim(&anim_activated);
    }
    engine.baseUpdate(self);
}

fn touch(self: *Entity, _: *Entity) void {
    if (self.entity.respawn_pod.activated) {
        return;
    }
    self.entity.respawn_pod.activated = true;
    self.base.anim = zi.anim(&anim_activated);
    sgame.setCheckpoint(engine.entityRef(self));
    zi.sound.play(sound_activated);
}

fn message(self: *Entity, m: ?*anyopaque, _: ?*anyopaque) void {
    const msg: game.EntityMessage = @enumFromInt(@intFromPtr(m));
    if (msg == .EM_ACTIVATE) {
        self.base.anim = zi.anim(&anim_respawn);
    }
}

pub var vtab: zi.EntityVtab(Entity) = .{
    .load = load,
    .init = init,
    .update = update,
    .touch = touch,
    .message = message,
};
