const std = @import("std");
const sokol = @import("sokol");
const sapp = sokol.app;
const zi = @import("zimpact");
const g = @import("global.zig");
const game = @import("game.zig");
const player = @import("entities/player.zig");
const title = @import("scenes/title.zig");

/// -----------------------------------------------------------------------------
/// Z Impact configuration
///
/// These defines are ALL optional. They overwrite the defaults set by
/// z_impact and configure aspects of the library
///
/// The values here (particularly resource limits) have been dialed in to this
/// particular game. Increase them as needed. Allocating a few GB and thousands
/// of entities is totally fine.
pub const zi_options = .{
    .ALLOC_SIZE = (62 * 1024 * 1024),
    .ALLOC_TEMP_OBJECTS_MAX = 8,
    .ENGINE_MAX_TICK = 0.1,
    .ENGINE_MAX_BACKGROUND_MAPS = 4,
    .ENTITIES_MAX = 1024,
    .ENTITY_MAX_SIZE = 64,
    .ENTITY_MIN_BOUNCE_VELOCITY = 10,
    .ENTITY_TYPE = game.UEntity,
    .RENDER_RESIZE_MODE = zi.options.RENDER_RESIZE_WIDTH,
    .RENDER_SIZE = zi.vec2i(240, 160),
    .RENDER_SCALE_MODE = zi.options.RENDER_SCALE_DISCRETE,
    .WINDOW_TITLE = "Z Biolab Disaster",
    .WINDOW_SIZE = zi.vec2i(240, 160).muli(4),
    .SOUND_MAX_UNCOMPRESSED_SAMPLES = 64 * 1024,
    .SOUND_MAX_SOURCES = 64,
    .SOUND_MAX_NODES = 256,
};

fn init() void {
    g.font = zi.font("assets/font_04b03.qoi", "assets/font_04b03.json");

    // Gamepad
    zi.input.bind(.INPUT_GAMEPAD_DPAD_LEFT, player.LEFT);
    zi.input.bind(.INPUT_GAMEPAD_DPAD_RIGHT, player.RIGHT);
    zi.input.bind(.INPUT_GAMEPAD_L_STICK_LEFT, player.LEFT);
    zi.input.bind(.INPUT_GAMEPAD_L_STICK_RIGHT, player.RIGHT);
    zi.input.bind(.INPUT_GAMEPAD_X, player.JUMP);
    zi.input.bind(.INPUT_GAMEPAD_B, player.JUMP);
    zi.input.bind(.INPUT_GAMEPAD_A, player.SHOOT);

    // Keyboard
    zi.input.bind(.INPUT_KEY_LEFT, player.LEFT);
    zi.input.bind(.INPUT_KEY_RIGHT, player.RIGHT);
    zi.input.bind(.INPUT_KEY_X, player.JUMP);
    zi.input.bind(.INPUT_KEY_C, player.SHOOT);

    g.noise = zi.noise.noise(8);
    g.player = zi.entity.entityRefNone();
    g.music = zi.sound.sound(zi.sound.source("assets/music/biochemie.qoa")).?;
    zi.sound.setLoop(g.music, true);

    zi.sound.setGlobalVolume(0.75);
    zi.Engine.setScene(&title.scene);
}

pub fn main() void {
    const vtabs = [_]zi.EntityVtab{
        game.blob.vtab,
        game.crate.vtab,
        game.debris.vtab,
        game.delay.vtab,
        game.dropper.vtab,
        game.earthquake.vtab,
        game.end_hub.vtab,
        game.end_hub_fade.vtab,
        game.end_hub_plasma.vtab,
        game.glass_dome.vtab,
        game.grunt.vtab,
        game.hurt.vtab,
        game.level_change.vtab,
        game.mine.vtab,
        game.mover.vtab,
        game.particle.vtab,
        game.player.vtab,
        game.projectile.vtab,
        game.respawn_pod.vtab,
        game.spewer.vtab,
        game.spewer_shot.vtab,
        game.spike.vtab,
        game.test_tube.vtab,
        game.trigger.vtab,
        game.ent_void.vtab,
    };

    zi.Engine.run(.{
        .vtabs = &vtabs,
        .init = init,
    });
}
