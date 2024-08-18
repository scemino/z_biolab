const std = @import("std");
const zi = @import("zimpact");
const game = @import("../game.zig");
const Entity = game.Entity;

pub var vtab: zi.EntityVtab(Entity) = .{};
