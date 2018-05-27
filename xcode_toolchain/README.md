Xcode Toolchain
===============

A CMake script to create LLVM and Clang toolchain for Xcode
from [Apple Swift source code repository](https://github.com/apple/swift-clang).

Requirements
------------

This CMake script requires next components.

 * macOS, Xcode 8.0 or newer
 * [CMake](https://cmake.org/) 3.10 or newer
 * [Ninja](https://ninja-build.org/)
 * [Git](https://git-scm.com/)

Usage
-----

> **NOTE:** Due to the escape issues in CMake scripts of LLVM projects, the full path to `build` directory
> _MUST NOT_ include any spaces or manually apply this [patch](https://gist.github.com/niw/ef33733d3781986cd28f31f41f1a45c2).

Install requirements. Recommend to use [Homebrew](https://brew.sh/).

    $ brew install git ninja cmake

Use CMake to generate Ninja build configuration, then build it.

    $ mkdir build
    $ cd build
    $ cmake -G Ninja ../
    $ cmake --build .
    # To use the toolchain with local Xcode, use next target.
    $ cmake --build . --target apple_llvm-symlink_xcode_toolchain
    # To create a distibution zip archive, use next target.
    $ cmake --build . --target apple_llvm-create_xcode_toolchain_distribution_archive

The bundle and, or the distribution zip archive are created in `apple_llvm-prefix`.

The build may take about an hour or more, depends on the environment.
The distribution zip archive may be about 1.5G bytes.

Targets
-------

Default target builds LLVM, compiler-rt, and Clang then install it as `.xctoolchain` bundle.

Use `apple_llvm-symlink_xcode_toolchain` target to create a symbolic link of the bundle to
`~/Library/Developer/Toolchains`, so that local Xcode can use it.

Use `apple_llvm-create_xcode_toolchain_distribution_archive` target to create a distribution
zip archive of the bundle.

Configurations
--------------

See `CMakeLists.txt`. Each `XCODE_TOOLCHAIN_…` prefixed cached variable is configurable.
