const std = @import("std");
const sokol = @import("sokol");
const sapp = sokol.app;
const stm = sokol.time;
const zi = @import("zimpact");
const Engine = zi.Engine;
const render = zi.render;
const rgba = zi.rgba;
const Map = zi.Map;
const entity = zi.entity;
const font = zi.font;
const input = zi.input;
const EntityVtab = zi.EntityVtab;
const platform = zi.platform;
const vec2i = zi.vec2i;
const g = @import("global.zig");
const player = @import("entities/player.zig");

const game = @import("game.zig");
const title = @import("scenes/title.zig");

const engine = Engine(game.Entity, game.EntityKind);
var vtabs: [@typeInfo(game.EntityKind).Enum.fields.len]EntityVtab(game.Entity) = undefined;

fn main_init() void {
    g.font = font("assets/font_04b03.qoi", "assets/font_04b03.json");

    // Gamepad
    input.bind(.INPUT_GAMEPAD_DPAD_LEFT, player.LEFT);
    input.bind(.INPUT_GAMEPAD_DPAD_RIGHT, player.RIGHT);
    input.bind(.INPUT_GAMEPAD_L_STICK_LEFT, player.LEFT);
    input.bind(.INPUT_GAMEPAD_L_STICK_RIGHT, player.RIGHT);
    input.bind(.INPUT_GAMEPAD_X, player.JUMP);
    input.bind(.INPUT_GAMEPAD_B, player.JUMP);
    input.bind(.INPUT_GAMEPAD_A, player.SHOOT);

    // Keyboard
    input.bind(.INPUT_KEY_LEFT, player.LEFT);
    input.bind(.INPUT_KEY_RIGHT, player.RIGHT);
    input.bind(.INPUT_KEY_X, player.JUMP);
    input.bind(.INPUT_KEY_C, player.SHOOT);

    g.noise = zi.noise.noise(8);
    g.player = entity.entityRefNone();
    // g.music = zi.sound.sound(zi.sound.source("assets/music/biochemie.qoa")).?;
    // zi.sound.setLoop(g.music, true);

    zi.sound.setGlobalVolume(0.75);

    engine.setScene(&title.scene);
}

export fn init() void {
    stm.setup();

    zi.utils.randSeed(@intFromFloat(engine.time_real * 10000000.0));

    vtabs = [_]EntityVtab(game.Entity){
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

    engine.init(.{
        .vtabs = &vtabs,
        .render_size = vec2i(240, 160),
        .main_init = main_init,
    });
}

export fn update() void {
    engine.update();
}

export fn cleanup() void {
    engine.cleanup();
}

pub fn main() void {
    sapp.run(.{
        .init_cb = init,
        .frame_cb = update,
        .cleanup_cb = cleanup,
        .event_cb = &platform.platformHandleEvent,
        .window_title = "Z Biolab",
        .width = 240 * 4,
        .height = 160 * 4,
    });
}
