const zi = @import("zimpact");

pub var font: *zi.Font = undefined;
pub var noise: *zi.Noise = undefined;
pub var music: zi.sound.Sound = undefined;

pub var player: zi.EntityRef = undefined;

pub var death_count: usize = 0;
pub var tubes_collected: usize = 0;
pub var tubes_total: usize = 0;
pub var level_time: f32 = 0;
