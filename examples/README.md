Examples
========

This directory contains each standalone tool, plugin works while Xcode is compiling source codes,
and analyzer checker works alongside Xcode user interface.

## CMake variables

Each plugin or analyzer checker works with Apple’s Xcode without custom toolchain and configured
to be used with system’s default Xcode toolchain.
However, if you want to use these with a specific version of Xcode, for example, the beta version of Xcode,
set these variables.

* `CLANG_PLUGINS_EXAMPLES_XCODE_TOOLCHAIN`

    Name of Xcode toolchain that is used by the example Xcode project.
    This is not for building these example Clang tool, plugin, or analyzer checker
    but for using these plugin or analyzer checker.
    Default to using the Xcode default toolchain.

* `CLANG_PLUGINS_EXAMPLES_CLANG_VERSION`

    Clang version that is used by the example Xcode project.
    This is used for Clang analyzer checker.
    In case using example Clang analyzer checker in the different Xcode from the system’s default one,
    like the beta version of it, set appropriate version.
    For example, `"10.0.0"` for Xcode 10.0.
    Default to the Clang version that given Xcode toolchain is using.

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

Select the default scheme and build for running.
In the build messages, it may print something extra line for `example.m`.

Clang analyzer checker
----------------------

Implemented in `example_checker.cpp`. You can use this plugin in Xcode.

See <https://clang-analyzer.llvm.org/checker_dev_manual.html>.

### Usage

Build the project by using CMake, then open `Example.xcodeproj` in Xcode.

Select the default scheme and analyze it.
You may see a custom analyzer error on `example.m`.
