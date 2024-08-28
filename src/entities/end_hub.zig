// EDITOR_SIZE(24, 24);
// EDITOR_RESIZE(false);
// EDITOR_COLOR(81, 132, 188);

const std = @import("std");
const zi = @import("zimpact");
const game = @import("../game.zig");
const g = @import("../global.zig");
const credits = @import("../scenes/credits.zig");
const Entity = zi.Entity;
const vec2 = zi.vec2;
const vec2i = zi.vec2i;
const engine = zi.Engine;

var anim_idle: zi.AnimDef = undefined;
var anim_activated: zi.AnimDef = undefined;
var sound_activate: *zi.sound.SoundSource = undefined;
var sound_the_end: *zi.sound.SoundSource = undefined;

fn load() void {
    const sheet = zi.image("assets/sprites/endhub.qoi");

    anim_idle = zi.animDef(sheet, vec2i(24, 24), 0.5, &[_]u16{ 0, 1 }, true);
    anim_activated = zi.animDef(sheet, vec2i(24, 24), 0.5, &[_]u16{ 2, 3 }, true);

    sound_activate = zi.sound.source("assets/sounds/respawn-activate.qoa");
    sound_the_end = zi.sound.source("assets/sounds/theend.qoa");
}

fn init(self: *Entity) void {
    self.anim = zi.anim(&anim_idle);
    self.size = vec2(24, 24);
    self.draw_order = -1;
}

fn update(self: *Entity) void {
    if (self.entity.end_hub.stage >= 1) {
        var v = zi.sound.volume(g.music);
        v -= @as(f32, @floatCast(zi.engine.tick)) * 0.25;
        zi.sound.setVolume(g.music, v);
    }
}

fn trigger(self: *Entity, _: *Entity) void {
    // The end hub gets triggered multiple time through delays; each time we
    // start a new stage of the animation.

    self.entity.end_hub.stage += 1;

    if (self.entity.end_hub.stage == 1) {
        zi.sound.play(sound_activate);
        self.anim = zi.anim(&anim_activated);
    }

    // Stage 2 - plasma animation
    else if (self.entity.end_hub.stage == 2) {
        zi.sound.play(sound_the_end);
        const sp = vec2(self.pos.x, self.pos.y - 24);
        for (0..100) |i| {
            if (zi.entity.entitySpawn(.end_hub_plasma, sp)) |p| {
                p.entity.end_hub_plasma.index = @intCast(i);
            }
        }
    }

    // Stage 3 - fade to white
    else if (self.entity.end_hub.stage == 3) {
        _ = zi.entity.entitySpawn(.end_hub_fade, self.pos);
    }

    // Stage 4 - end the game
    else if (self.entity.end_hub.stage == 4) {
        engine.setScene(&credits.scene);
    }
}

pub const vtab: zi.EntityVtab = .{
    .load = load,
    .init = init,
    .update = update,
    .trigger = trigger,
};
