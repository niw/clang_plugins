Xcode plugin to use self-build clang toolchain
===

There is a secret plugin that represents `clang` toolchain in Xcode.
By adding a modified version of it, we can control which `clang` Xcode uses.

Overview
---

The plugin is based on the orignal `/Applications/Xcode.app/Contents/PlugIns/Xcode3Core.ideplugin/Contents/SharedSupport/Developer/Library/Xcode/Plug-ins/Clang LLVM 1.0.xcplugin`.

 * `Contents/Info.plist`

   Change `DTCompiler` and `CFBundleIdentifier`.
   Remove unnecessary fields.
   Also converted into XML format from binary plist, so that we can trace changes in the source repository.

 * `Contents/Resources/Clang LLVM 1.0.xcspec`

   Change every `Identifier`, `BasedOn`, `Name`, and `Description`.
   Add `CLANG_BIN_PATH` option, then use it for `ExecPath` and `ExecCPlusPlusLinkerPath`.

We only need `Contents/Info.plist` and `Contents/Resources/Clang LLVM 1.0.xcspec`, so remove any other files.

Use self-build toolchain
---

Set next build options to the project configuration (`.xcconfig` file.)

    GCC_VERSION = com.apple.compilers.llvm.clang.1_0_custom
    CLANG_BIN_PATH = /path/to/llvm-macosx-x86_64/bin
    OTHER_LDFLAGS = $(inherited) $(DT_TOOLCHAIN_DIR)/usr/lib/clang/9.1.0/lib/darwin/libclang_rt.ios.a

`GCC_VERSION` switches which `clang` toolchain provided by the plugin is used by the project.
`CLANG_BIN_PATH` is for self-build `clang` bin path.

This `libclang_rt.ios.a` is needed to build iOS project, which is closed source and not available in Apple open source project.
If you don’t have this, you may not be able to use `@available` which reuqires `___isOSVersionAtLeast`.

## Clang analyzer checkers

To use custom Clang analyzer checkers, set next build options to the project configuration alongside with the previous options.

    CLANG_ANALYZER_EXEC = $(CLANG_BIN_PATH)/clang
    CLANG_ANALYZER_OTHER_FLAGS = -load /path/to/custom/analyzer/plugin.dylib
    CLANG_ANALYZER_OTHER_CHECKERS = extra.AnalyzerChecker ...

