// EDITOR_SIZE(8, 10);
// EDITOR_RESIZE(false);
// EDITOR_COLOR(81, 132, 188);

const std = @import("std");
const zi = @import("zimpact");
const game = @import("../game.zig");
const g = @import("../global.zig");
const sgame = @import("../scenes/game.zig");
const Entity = zi.Entity;
const vec2 = zi.vec2;
const vec2i = zi.vec2i;
const engine = zi.Engine;

var anim_idle: zi.AnimDef = undefined;
var sound_collect: *zi.sound.SoundSource = undefined;

fn load() void {
    const sheet = zi.image("assets/sprites/test-tube.qoi");
    anim_idle = zi.animDef(sheet, vec2i(8, 10), 0.1, &[_]u16{ 0, 0, 0, 1, 2, 3, 0, 0, 0, 2, 0, 0, 1, 0, 0 }, true);
    sound_collect = zi.sound.source("assets/sounds/collect.qoa");
}

fn init(self: *Entity) void {
    self.anim = zi.anim(&anim_idle);
    self.anim.gotoRand();
    self.size = vec2(8, 10);
    self.check_against = zi.entity.ENTITY_GROUP_PLAYER;
}

fn touch(self: *Entity, _: *Entity) void {
    zi.entity.entityKill(self);
    zi.sound.play(sound_collect);
    g.tubes_collected += 1;
}

pub const vtab: zi.EntityVtab = .{
    .load = load,
    .init = init,
    .touch = touch,
};
