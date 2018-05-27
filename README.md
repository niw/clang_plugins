Clang plugins
=============

This is a repository for Clang plugins examples and development, that works alongside Xcode.

You can implement your own Clang plugins to extend your day-to-day Xcode workflow,
like custom Analyzer checker to warn cording rules or source-to-source converter for refactoring.

Contents
--------

### `xcode_toolchain`

This directory contains CMake scripts that build custom Xcode toolchain from Apple Swift source tree.
See `xcode_toolchain/README.md` for the details.

### `examples`

This directory contains Clang plugin examples and Xcode project that is using these plugins.
See `examples/README.md` for the details.

Usage
-----

First, build your own custom Xcode toolchain. This step takes longer time.

    $ brew install cmake ninja
    $ cd xcode_toolchain
    $ mkdir build
    $ cd build
    $ cmake -G Ninja ../
    $ cmake --build . --target apple_llvm-symlink_xcode_toolchain

Then, build the project, including examples.

    $ cd ..
    $ mkdir build
    $ cd build
    $ cmake -DCLANG_PLUGINS_XCODE_TOOLCHAIN=Custom ../
    $ cmake --build .

It creates all example plugins. Open `examples/Example.xcodeproj` in Xcode and build example project or
analyze it to see how each plugin works.

You can use [CLion](https://www.jetbrains.com/clion/) to import this project.
Set `-DCLANG_PLUGINS_XCODE_TOOLCHAIN=Custom` at CMake options in CMake pane of Build, Execution, Deployment section
in the project preferences.
