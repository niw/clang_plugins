Examples
========

This directory contains each standalone tool, plugin works while compiling, and analyzer checker.

Standalone Clang tool
---------------------

Implemented in `example_tool.cpp`. You can use this tool as a standalone tool.

See also <https://clang.llvm.org/docs/LibTooling.html>.

### Usage

To use Clang tool with normal Objective-C code, give next arguments.

We need to set resource dir fixed to the relative `../lib/clang/<clang version>` in `clang` binary.

    $ example_tool \
      -extra-arg -fmodules \
      -extra-arg -isysroot \
      -extra-arg "$(xcrun --sdk macosx --show-sdk-path)" \
      -extra-arg -resource-dir \
      -extra-arg "$(dirname "$(xcrun --toolchain <Xcode toolchain name> --find clang)")/../lib/clang/<clang version>"

Where `<Xcode toolchain name>` may be `Custom` and `<clang version>` is `6.0.1` or something.

Clang plugin
------------

Implemented in `example_plugin.cpp`. You can use this plugin in Xcode.

See also <https://clang.llvm.org/docs/ClangPlugins.html>.

### Usage

Build the project by using CMake, then open `Example.xcodeproj` in Xcode.

Select default scheme and build for running.
In the build messages, it may print something extra line for `example.m`.

Clang analyzer checker
----------------------

Implemented in `example_checker.cpp`. You can use this plugin in Xcode.

See <https://clang-analyzer.llvm.org/checker_dev_manual.html>.

### Usage

Build the project by using CMake, then open `Example.xcodeproj` in Xcode.

Select default scheme and analyze it.
You may see a custom analyzer error on `example.m`.
