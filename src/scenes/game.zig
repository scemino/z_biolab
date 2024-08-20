const std = @import("std");
const zi = @import("zimpact");
const game = @import("../game.zig");
const g = @import("../global.zig");
const Scene = zi.Scene;
const Image = zi.Image;
const font = zi.font;
const scale = zi.utils.scale;
const vec2 = zi.vec2;
const Vec2 = zi.Vec2;
const camera_t = zi.camera_t;

var level_path: []const u8 = undefined;
var initial_spawn_pos: Vec2 = vec2(0, 0);
var camera: camera_t = .{};
var last_checkpoint: zi.EntityRef = undefined;

pub fn setLevelPath(path: []const u8) void {
    level_path = path;
}

pub fn setCheckpoint(checkpoint: zi.EntityRef) void {
    last_checkpoint = checkpoint;
}

pub fn respawn() void {
    var pos = initial_spawn_pos;

    if (game.engine.entityByRef(last_checkpoint)) |respawn_pod| {
        pos = respawn_pod.base.pos.add(vec2(11, 0));
        game.engine.entityMessage(respawn_pod, game.EntityMessage.EM_ACTIVATE, null);
    }

    g.player = game.engine.entityRef(game.engine.spawn(.player, pos).?);
    camera.follow(game.engine, g.player, false);
    g.death_count += 1;
}

pub fn spawnParticle(pos: Vec2, vel: f32, vel_variance: f32, angle: f32, angle_variance: f32, sheet: *zi.AnimDef) ?*game.Entity {
    if (game.engine.spawn(.particle, pos)) |particle| {
        particle.base.anim = zi.anim(sheet);
        particle.base.anim.gotoRand();
        particle.base.anim.flip_x = zi.utils.randInt(0, 1) > 0;
        particle.base.anim.flip_y = zi.utils.randInt(0, 1) > 0;

        const a = zi.utils.randFloat(angle - angle_variance, angle + angle_variance);
        const v = zi.utils.randFloat(vel - vel_variance, vel + vel_variance);
        particle.base.vel = zi.types.fromAngle(a).mulf(v);
        return particle;
    }
    return null;
}

fn init() void {
    game.engine.loadLevel(game.EntityKind, level_path);
    game.engine.gravity = 240;

    for (zi.engine.background_maps) |map| {
        if (map) |m| {
            m.setAnim(80, 0.13, &[_]u16{ 80, 81, 82, 83, 84, 85, 86, 87 });
            m.setAnim(81, 0.17, &[_]u16{ 84, 83, 82, 81, 80, 87, 86, 85 });
            m.setAnim(88, 0.23, &[_]u16{ 88, 89, 90, 91, 92, 93, 94, 95 });
            m.setAnim(89, 0.19, &[_]u16{ 95, 94, 93, 92, 91, 90, 89, 88 });
        }
    }

    camera.offset = vec2(32, 0);
    camera.speed = 3;
    camera.min_vel = 5;

    last_checkpoint = zi.entity.entityRefNone();

    const players = game.engine.entitiesByType(.player);
    if (players.items.len > 0) {
        g.player = players.items[0];
        camera.follow(game.engine, g.player, true);
        const player_ent = game.engine.entityByRef(g.player);
        initial_spawn_pos = player_ent.?.base.pos;
    }

    g.tubes_collected = 0;
    g.death_count = 0;
    g.tubes_total = game.engine.entitiesByType(.test_tube).items.len;
}

fn update() void {
    game.engine.sceneBaseUpdate();

    camera.update(game.engine);
}

fn draw() void {
    game.engine.baseDraw();

    // var buf: [128]u8 = undefined;
    // const text = std.fmt.bufPrint(&buf, "total: {d:.2}ms, update: {d:.2}ms, draw: {d:.2}ms\ndraw calls: {}, entities: {}, checks: {}", .{ engine.perf.total * 1000, engine.perf.update * 1000, engine.perf.draw * 1000, engine.perf.draw_calls, engine.perf.entities, engine.perf.checks }) catch @panic("failed to format string");
    // // Draw some debug info...
    // g.font.draw(vec2(2, 2), text, .FONT_ALIGN_LEFT);
}

fn cleanup() void {
    g.level_time = @as(f32, @floatCast(zi.engine.time));
}

pub const scene: Scene = .{
    .init = init,
    .update = update,
    .draw = draw,
    .cleanup = cleanup,
};
