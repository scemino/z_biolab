const std = @import("std");
const zi = @import("zimpact");
pub const blob = @import("entities/blob.zig");
pub const player = @import("entities/player.zig");
pub const projectile = @import("entities/projectile.zig");
pub const particle = @import("entities/particle.zig");
pub const earthquake = @import("entities/earthquake.zig");
pub const trigger = @import("entities/trigger.zig");
pub const debris = @import("entities/debris.zig");
pub const crate = @import("entities/crate.zig");
pub const respawn_pod = @import("entities/respawn_pod.zig");
pub const test_tube = @import("entities/test_tube.zig");
pub const mine = @import("entities/mine.zig");
pub const glass_dome = @import("entities/glass_dome.zig");
pub const hurt = @import("entities/hurt.zig");
pub const level_change = @import("entities/level_change.zig");
pub const mover = @import("entities/mover.zig");
pub const delay = @import("entities/delay.zig");
pub const ent_void = @import("entities/void.zig");
pub const end_hub = @import("entities/end_hub.zig");
pub const end_hub_fade = @import("entities/end_hub_fade.zig");
pub const end_hub_plasma = @import("entities/end_hub_plasma.zig");
pub const dropper = @import("entities/dropper.zig");
pub const grunt = @import("entities/grunt.zig");
pub const spike = @import("entities/spike.zig");
pub const spewer = @import("entities/spewer.zig");
pub const spewer_shot = @import("entities/spewer_shot.zig");
pub const engine = zi.Engine(Entity);

pub const EntityMessage = enum {
    EM_INVALID,
    EM_ACTIVATE,
};

pub const EntityKind = enum {
    blob,
    crate,
    debris,
    delay,
    dropper,
    earthquake,
    end_hub,
    end_hub_fade,
    end_hub_plasma,
    glass_dome,
    grunt,
    hurt,
    level_change,
    mine,
    mover,
    particle,
    player,
    projectile,
    respawn_pod,
    spewer,
    spewer_shot,
    spike,
    test_tube,
    trigger,
    void,
};

pub const UEntity = struct {
    blob: struct {
        in_jump: bool,
        seen_player: bool,
        jump_timer: f32,
    },
    debris: struct {
        count: usize,
        duration: f32,
        duration_time: f32,
        emit_time: f32,
    },
    delay: struct {
        targets: std.ArrayList(zi.EntityRef),
        triggered_by: zi.EntityRef,
        fire: bool,
        delay: f32,
        delay_time: f32,
    },
    dropper: struct {
        shoot_wait_time: f32,
        shoot_time: f32,
        can_shoot: bool,
    },
    earthquake: struct {
        duration: f32,
        strength: f32,
        time: f32,
    },
    end_hub: struct {
        stage: i32,
    },
    end_hub_plasma: struct {
        time: f32,
        index: usize,
    },
    end_hub_fade: struct {
        time: f32,
    },
    grunt: struct {
        shoot_time: f32,
        flip: bool,
        seen_player: bool,
    },
    hurt: struct {
        damage: f32,
    },
    level_change: struct {
        path: []const u8,
    },
    mover: struct {
        targets: std.ArrayList(zi.EntityRef),
        current_target: usize,
        speed: f32,
    },
    particle: struct {
        life_time: f32,
        fade_time: f32,
    },
    player: struct {
        high_jump_time: f32,
        idle_time: f32,
        flip: bool,
        can_jump: bool,
        is_idle: bool,
    },
    projectile: struct {
        anim_hit: *zi.AnimDef,
        has_hit: bool,
        flip: bool,
    },
    respawn_pod: struct {
        activated: bool,
    },
    spewer: struct {
        shoot_wait_time: f32,
        shoot_time: f32,
        can_shoot: bool,
    },
    spewer_shot: struct {
        bounce_count: usize,
    },
    spike: struct {
        shoot_wait_time: f32,
        shoot_time: f32,
        can_shoot: bool,
        flip: bool,
    },
    trigger: struct {
        targets: std.ArrayList(zi.EntityRef),
        delay: f32,
        delay_time: f32,
        can_fire: bool,
    },
};

pub const Entity = struct {
    base: zi.EntityBase,
    kind: EntityKind,
    entity: UEntity,
};
