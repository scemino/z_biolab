const std = @import("std");
const sokol = @import("sokol");
const sapp = sokol.app;
const zi = @import("zimpact");
const g = @import("global.zig");
const game = @import("game.zig");
const player = @import("entities/player.zig");
const title = @import("scenes/title.zig");

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
    // g.music = zi.sound.sound(zi.sound.source("assets/music/biochemie.qoa")).?;
    // zi.sound.setLoop(g.music, true);

    zi.sound.setGlobalVolume(0.75);

    game.engine.setScene(&title.scene);
}

pub fn main() void {
    const vtabs = [_]zi.EntityVtab(game.Entity){
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

    game.engine.run(.{
        .vtabs = &vtabs,
        .window_title = "Z Biolab Disaster",
        .render_size = zi.vec2i(240, 160),
        .window_size = zi.vec2i(240, 160).muli(4),
        .init = init,
    });
}
