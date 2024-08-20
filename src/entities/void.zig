const std = @import("std");
const zi = @import("zimpact");
const game = @import("../game.zig");
const Entity = game.Entity;

pub const vtab: zi.EntityVtab(Entity) = .{};
