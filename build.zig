const std = @import("std");
const sokol = @import("sokol");
const sdl = @import("sdl");
const zi = @import("zimpact");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const opt_platform = b.option(zi.PlatformAndRenderer, "platform", "Platform to use: sdl, sdl_soft or sokol");
    const platform_renderer = if (target.result.cpu.arch.isWasm()) .sokol else opt_platform orelse .sdl_soft;

    // build Z Biolab sample
    const sample: []const u8 = "zbiolab";
    const dep_zi = b.dependency("zimpact", .{
        .optimize = optimize,
        .target = target,
        .platform = platform_renderer,
    });

    const assets_dir: []const u8 = "assets";
    const assets_step = b.step("game_assets", "Build game assets");
    try zi.buildAssets(b, .{
        .assets_step = assets_step,
        .asset_dir = assets_dir,
        .qoiconv_exe = dep_zi.artifact("qoiconv"),
        .qoaconv_exe = dep_zi.artifact("qoaconv"),
    });

    const mod_main = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "zimpact", .module = dep_zi.module("zimpact") },
        },
    });

    if (target.result.cpu.arch.isWasm()) {
        try zi.buildWasm(b, .{
            .mod_main = mod_main,
            .dep_sokol = dep_zi.builder.dependency("sokol", .{}),
            .assets_step = assets_step,
            .shell_file_path = dep_zi.builder.path("web/shell.html"),
        });
    } else {
        const run_step = b.step(b.fmt("run", .{}), "Run zbiolab");
        const exe = b.addExecutable(.{
            .name = sample,
            .root_module = mod_main,
        });
        if (platform_renderer == .sdl or platform_renderer == .sdl_soft) {
            const sdl_sdk = sdl.init(b, .{});
            sdl_sdk.link(exe, .dynamic, sdl.Library.SDL2);
        }
        const install_exe = b.addInstallArtifact(exe, .{});
        install_exe.step.dependOn(assets_step);
        b.getInstallStep().dependOn(&install_exe.step);

        const run_cmd = b.addRunArtifact(exe);
        run_cmd.step.dependOn(&install_exe.step);

        if (b.args) |args| {
            run_cmd.addArgs(args);
        }

        run_step.dependOn(&run_cmd.step);
    }
}
