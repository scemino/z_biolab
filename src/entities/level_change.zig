const std = @import("std");
const zi = @import("zimpact");
const game = @import("../game.zig");
const scene_game = @import("../scenes/game.zig");
const stats = @import("../scenes/stats.zig");
const Entity = game.Entity;
const vec2 = zi.vec2;
const engine = zi.Engine(game.Entity, game.EntityKind);

fn settings(self: *Entity, s: std.json.ObjectMap) void {
    self.entity.level_change.path = s.get("level").?.string;
}

fn trigger(self: *Entity, _: *Entity) void {
    scene_game.setLevelPath(self.entity.level_change.path);
    engine.setScene(&stats.scene);
}

pub var vtab: zi.EntityVtab(Entity) = .{
    .settings = settings,
    .trigger = trigger,
};
