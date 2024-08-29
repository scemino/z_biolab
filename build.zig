const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const dep_sokol = b.dependency("sokol", .{
        .target = target,
        .optimize = optimize,
    });

    const dep_zi = b.dependency("zimpact", .{
        .target = target,
        .optimize = optimize,
    });

    const exe = b.addExecutable(.{
        .name = "zbiolab",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe.root_module.addImport("sokol", dep_sokol.module("sokol"));
    exe.root_module.addImport("zimpact", dep_zi.module("zimpact"));

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // build qoiconv executable
    const qoiconv_exe = b.addExecutable(.{
        .name = "qoiconv",
        .target = b.host,
        .optimize = .ReleaseFast,
    });
    qoiconv_exe.addCSourceFile(.{
        .file = b.path("tools/qoiconv.c"),
        .flags = &[_][]const u8{"-std=c99"},
    });

    const qoiconv_step = b.step("qoiconv", "Build qoiconv");
    qoiconv_step.dependOn(&qoiconv_exe.step);

    // build qoaconv executable
    const qoaconv_exe = b.addExecutable(.{
        .name = "qoaconv",
        .target = b.host,
        .optimize = .ReleaseFast,
    });
    qoaconv_exe.addCSourceFile(.{
        .file = b.path("tools/qoaconv.c"),
        .flags = &[_][]const u8{"-std=c99"},
    });

    const qoaconv_step = b.step("qoaconv", "Build qoaconv");
    qoaconv_step.dependOn(&qoaconv_exe.step);

    const asset_dir = "assets";
    const dir = try std.fs.cwd().openDir(asset_dir, .{ .iterate = true });
    var walker = try dir.walk(b.allocator);
    defer walker.deinit();

    while (try walker.next()) |assets_file| {
        switch (assets_file.kind) {
            .directory => {},
            .file => {
                const ext = std.fs.path.extension(assets_file.path);
                const file = std.fs.path.stem(assets_file.basename);

                const input = b.fmt("{s}/{s}", .{ asset_dir, assets_file.path });
                const out_dir = std.fs.path.dirname(assets_file.path);
                if (std.mem.eql(u8, ext, ".png")) {
                    // convert .png to .qoi
                    const output = if (out_dir) |d| b.fmt("assets/{s}/{s}.qoi", .{ d, file }) else b.fmt("assets/{s}.qoi", .{file});
                    convert(b, qoiconv_exe, input, output);
                } else if (std.mem.eql(u8, ext, ".wav")) {
                    // convert .wav to .qoa
                    const output = if (out_dir) |d| b.fmt("assets/{s}/{s}.qoa", .{ d, file }) else b.fmt("assets/{s}.qoa", .{file});
                    convert(b, qoaconv_exe, input, output);
                } else {
                    // just copy the asset
                    const output = if (out_dir) |d| b.fmt("assets/{s}/{s}{s}", .{ d, file, ext }) else b.fmt("assets/{s}{s}", .{ file, ext });
                    b.getInstallStep().dependOn(&b.addInstallFileWithDir(b.path(input), .bin, output).step);
                }
            },
            else => {},
        }
    }
}

fn convert(b: *std.Build, tool: *std.Build.Step.Compile, input: []const u8, output: []const u8) void {
    const tool_step = b.addRunArtifact(tool);
    tool_step.addFileArg(b.path(input));
    const out = tool_step.addOutputFileArg(std.fs.path.basename(output));
    b.getInstallStep().dependOn(&b.addInstallBinFile(out, output).step);
}
