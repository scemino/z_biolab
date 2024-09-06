# Biolab Disaster

This is the source code for the 2d platformer Biolab Disaster, using the [z impact](https://github.com/scemino/z_impact) game engine.

Z Biolab disaster is a port of the orginal game [high_biolab](https://github.com/phoboslab/high_biolab) made by phoboslab.

## Building

All the assets are converted during the build you have nothing more to do than:

### Linux - Windows - macOS

SDL2 platform

```shell
zig build run
```

sokol platform
```shell
zig build -Dplatform=sokol run
```

### Web

1. Clone this repository
2. `zig build -Doptimize=ReleaseSmall -Dtarget=wasm32-emscripten run`

## License

All z impact and game code is MIT Licensed, though some of the libraries come with their own (permissive) license. Check the header files.

**Note that the assets (sound, music, graphics) don't come with any license. You cannot use those in your own games**