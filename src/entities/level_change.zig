const std = @import("std");
const zi = @import("zimpact");
const game = @import("../game.zig");
const scene_game = @import("../scenes/game.zig");
const stats = @import("../scenes/stats.zig");
const Entity = zi.Entity;
const vec2 = zi.vec2;

var level_path_buffer: [64]u8 = undefined;

fn settings(self: *Entity, s: std.json.ObjectMap) void {
    var fba = std.heap.FixedBufferAllocator.init(&level_path_buffer);
    self.entity.level_change.path = fba.allocator().dupe(u8, s.get("level").?.string) catch @panic("failed ro setLevelPath");
}

fn trigger(self: *Entity, _: *Entity) void {
    scene_game.setLevelPath(self.entity.level_change.path);
    zi.Engine.setScene(&stats.scene);
}

pub const vtab: zi.EntityVtab = .{
    .settings = settings,
    .trigger = trigger,
};
