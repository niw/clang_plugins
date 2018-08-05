Clang plugins
=============

This is a repository for Clang plugins examples and development, that works alongside Xcode.

You can implement your own Clang plugins to extend your day-to-day Xcode workflow,
like custom analyzer checker to warn cording rules or source-to-source converter for refactoring.

Contents
--------

### `xcode_toolchain`

This directory contains CMake scripts that build custom Xcode toolchain from Apple’s Swift source tree.
See `xcode_toolchain/README.md` for the details.

### `examples`

This directory contains Clang tool, plugin and analyzer checker examples and Xcode project
that is using these plugin and analyzer checker.
See `examples/README.md` for the details.

Usage
-----

There are two steps to use this project.

### Create a custom Xcode toolchain

First, build your own custom Xcode toolchain that includes the LLVM and Clang libraries we need.
This step takes long time.

    $ brew install cmake ninja
    $ cd xcode_toolchain
    $ mkdir build
    $ cd build
    $ cmake -G Ninja ../
    $ cmake --build . --target apple_llvm-symlink_xcode_toolchain

See `xcode_toolchains/README.md` for the details.

### Build the project with examples.

Then, build the project, including examples.

    $ cd ..
    $ mkdir build
    $ cd build
    $ cmake -DCLANG_PLUGINS_XCODE_TOOLCHAIN=Custom ../
    $ cmake --build .

It creates all example plugins. Open `examples/Example.xcodeproj` in Xcode and build the example project
or analyze it to see how each plugin or analyzer checker works.

You can use [CLion](https://www.jetbrains.com/clion/) to import this project.
Set `-DCLANG_PLUGINS_XCODE_TOOLCHAIN=Custom` at CMake options in CMake pane of Build, Execution,
Deployment section in the project preferences.

### CMake variables

* `CLANG_PLUGINS_XCODE_TOOLCHAIN`

    Name of Xcode toolchain that is used for building these example Clang tool,
    plugin, or analyzer checker.
    Default to environment variable `TOOLCHAINS` as like how `xcrun` works.

There are a few extra CMake variables for examples.
See `examples/README.md` for the details.
