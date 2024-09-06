const std = @import("std");
const sokol = @import("sokol");
const sdl = @import("sdl");
const zi = @import("zimpact");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const platform = b.option([]const u8, "platform", "Plaftorm to use: sdl or sokol") orelse "sdl";
    const is_sdl_platform = !std.mem.eql(u8, platform, "sokol");

    // convert the assets and install them
    const asset_dir = "assets";
    const assets_step = try zi.buildAssets(b, asset_dir);

    // build Z Biolab sample
    const sample: []const u8 = "zbiolab";
    const mod_zi = zi.getZimpactModule(b, .{
        .optimize = optimize,
        .target = target,
        .sdl_platform = !target.result.isWasm() and is_sdl_platform,
    });

    if (!target.result.isWasm()) {
        const run_step = b.step(b.fmt("run", .{}), "Run zbiolab");
        // for native platforms, build into a regular executable
        const exe = b.addExecutable(.{
            .name = sample,
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        });
        if (is_sdl_platform) {
            const sdl_sdk = sdl.init(b, "");
            sdl_sdk.link(exe, .dynamic);
        }
        exe.root_module.addImport("zimpact", mod_zi);

        const run_cmd = b.addRunArtifact(exe);
        run_cmd.step.dependOn(&b.addInstallArtifact(exe, .{}).step);

        if (b.args) |args| {
            run_cmd.addArgs(args);
        }

        run_step.dependOn(assets_step);
        run_step.dependOn(&run_cmd.step);
    } else {
        try zi.buildWeb(b, .{
            .output_name = "zdrop",
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .assets_step = assets_step,
            .mod_zi = mod_zi,
        });
    }
}
