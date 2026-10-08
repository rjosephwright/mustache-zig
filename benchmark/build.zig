const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{
        .default_target = .{
            .cpu_model = .baseline,
        },
    });

    const mode = b.option(
        std.lang.Optimize,
        "optimize",
        "Prioritize performance, safety, or binary size",
    ) orelse .safe;

    const exe = b.addExecutable(.{
        .name = "benchmark",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/ramhorns_bench.zig"),
            .target = target,
            .optimize = mode,
            .link_libc = true,
        }),
    });
    exe.root_module.addAnonymousImport("mustache", .{
        .root_source_file = b.path("../src/mustache.zig"),
    });
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    run_cmd.addPassthruArgs();

    const run_step = b.step("run", "Run the benchmark");
    run_step.dependOn(&run_cmd.step);
}
