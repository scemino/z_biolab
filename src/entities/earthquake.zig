const std = @import("std");
const zi = @import("zimpact");
const game = @import("../game.zig");
const Entity = zi.Entity;
const vec2 = zi.vec2;

var sound_earthquake: *zi.sound.SoundSource = undefined;

fn load() void {
    sound_earthquake = zi.sound.source("assets/sounds/earthquake.qoa");
}

fn settings(self: *Entity, s: std.json.ObjectMap) void {
    self.entity.earthquake.strength = zi.utils.jsonFloat(s.get("strength"));
    self.entity.earthquake.duration = zi.utils.jsonFloat(s.get("duration"));
}

fn update(self: *Entity) void {
    if (self.entity.earthquake.time <= 0) {
        return;
    }

    self.entity.earthquake.time -= @as(f32, @floatCast(zi.engine.tick));

    const p = self.entity.earthquake.time / self.entity.earthquake.duration;
    const shake = self.entity.earthquake.strength * p * 0.5;
    if (shake > 0.5) {
        zi.engine.viewport.x += zi.utils.randFloat(-shake, shake);
        zi.engine.viewport.y += zi.utils.randFloat(-shake, shake);
    }
}

fn trigger(self: *Entity, _: *Entity) void {
    zi.sound.play(sound_earthquake);
    self.entity.earthquake.time = self.entity.earthquake.duration;
}

pub const vtab: zi.EntityVtab = .{
    .load = load,
    .settings = settings,
    .update = update,
    .trigger = trigger,
};
