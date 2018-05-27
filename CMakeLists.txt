cmake_minimum_required(VERSION 3.10)

project(clang_plugins)

set(CMAKE_MODULE_PATH
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake"
    "${CMAKE_CURRENT_SOURCE_DIR}/xcode_toolchain/cmake"
    ${CMAKE_MODULE_PATH})

include(XcodeToolchain)

# Use `TOOLCHAINS` as a default value for this as like how `xcrun` works.
set(CLANG_PLUGINS_XCODE_TOOLCHAIN "$ENV{TOOLCHAINS}"
  CACHE STRING "Xcode toolchain name to find LLVM and Clang.")

if(CLANG_PLUGINS_XCODE_TOOLCHAIN)
    # Use `xcrun --toolchain` to find the given Xcode toolchain.
    # If the Xcode toolchain has CMake modules, then use it.
    find_xcode_toolchain_path(XCODE_TOOLCHAIN_PATH ${CLANG_PLUGINS_XCODE_TOOLCHAIN})

    set(PREFIX_PATH ${XCODE_TOOLCHAIN_PATH}/lib/cmake/llvm)
    if(EXISTS ${PREFIX_PATH})
        set(LLVM_DIR ${PREFIX_PATH})
    endif()

    set(PREFIX_PATH ${XCODE_TOOLCHAIN_PATH}/lib/cmake/clang)
    if(EXISTS ${PREFIX_PATH})
        set(CLANG_DIR ${PREFIX_PATH})
    endif()
endif()

include(UseClang)

