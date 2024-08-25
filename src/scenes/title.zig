const std = @import("std");
const zi = @import("zimpact");
const game = @import("../game.zig");
const g = @import("../global.zig");
const scene_game = @import("game.zig");
const player = @import("../entities/player.zig");
const Scene = zi.Scene;
const Image = zi.Image;
const font = zi.font;
const engine = zi.engine;
const scale = zi.utils.scale;
const vec2 = zi.vec2;

var img_biolab: *Image = undefined;
var img_disaster: *Image = undefined;
var img_player: *Image = undefined;
var intro_sound_played: bool = false;
var sound_intro: *zi.sound.SoundSource = undefined;

fn init() void {
    img_biolab = Image.init("assets/title-biolab.qoi") catch @panic("failed to init image");
    img_disaster = Image.init("assets/title-disaster.qoi") catch @panic("failed to init image");
    img_player = Image.init("assets/title-player.qoi") catch @panic("failed to init image");

    sound_intro = zi.sound.source("assets/sounds/intro.qoa");
    intro_sound_played = false;
}

fn update() void {
    zi.Engine.sceneBaseUpdate();

    if (engine.time > 0.5 and !intro_sound_played) {
        zi.sound.play(sound_intro);
        intro_sound_played = true;
    }

    if (zi.input.pressed(player.SHOOT) or zi.input.pressed(player.JUMP)) {
        zi.sound.setTime(g.music, 0);
        zi.sound.setVolume(g.music, 1.0);
        zi.sound.unpause(g.music);

        scene_game.setLevelPath("assets/levels/biolab-1.json");
        zi.Engine.setScene(&scene_game.scene);
    }
}

fn draw() void {
    zi.Engine.sceneBaseDraw();

    const d: f32 = @as(f32, @floatCast(engine.time)) - 1.0;
    img_biolab.draw(vec2(scale(std.math.clamp(d * d * -d, 0, 1), 1.0, 0, -160, 44), 26));
    img_disaster.draw(vec2(scale(std.math.clamp(d * d * -d, 0, 1), 1.0, 0, 300, 44), 70));
    img_player.draw(vec2(scale(std.math.clamp(d * d * -d, 0, 1), 0.5, 0, 240, 166), 56));

    if (d > 2 or @mod(@as(i32, @intFromFloat(d * 2)), 2) == 0) {
        g.font.draw(vec2(120, 140), "Press X or C to Play", .FONT_ALIGN_CENTER);
    }
}

pub const scene: Scene = .{
    .init = init,
    .update = update,
    .draw = draw,
};
