cmake_minimum_required(VERSION 3.10)

project(clang_plugins)

# Use `TOOLCHAINS` as a default value for this as like how `xcrun` works.
set(CLANG_PLUGINS_XCODE_TOOLCHAIN "$ENV{TOOLCHAINS}"
  CACHE STRING "Xcode toolchain name to find LLVM and Clang.")

# Use `xcrun --toolcchain` to find the given Xcode toolchain.
# If the Xcode toolchain has CMake modules, then use it.
if(CLANG_PLUGINS_XCODE_TOOLCHAIN)
    set(XCRUN_COMMAND /usr/bin/xcrun)
    execute_process(
        COMMAND ${XCRUN_COMMAND} --toolchain ${CLANG_PLUGINS_XCODE_TOOLCHAIN} --find clang
        OUTPUT_VARIABLE CLANG_PATH
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_QUIET)

    get_filename_component(CLANG_DIR_PATH ${CLANG_PATH} DIRECTORY)
    get_filename_component(XCODE_TOOLCHAIN_PATH ${CLANG_DIR_PATH} DIRECTORY)

    set(PREFIX_PATH ${XCODE_TOOLCHAIN_PATH}/lib/cmake/llvm)
    if(EXISTS ${PREFIX_PATH})
        set(LLVM_DIR ${PREFIX_PATH})
    endif()

    set(PREFIX_PATH ${XCODE_TOOLCHAIN_PATH}/lib/cmake/clang)
    if(EXISTS ${PREFIX_PATH})
        set(CLANG_DIR ${PREFIX_PATH})
    endif()
endif()

# Find LLVM and Clang modules.
# Use `CLANG_PLUGINS_XCODE_TOOLCHAIN` or `CMAKE_PREFIX_PATH`, or `LLVM_DIR` and `CLANG_DIR`.
# See <https://cmake.org/cmake/help/v3.11/command/find_package.html>
find_package(LLVM REQUIRED CONFIG)
find_package(CLANG REQUIRED CONFIG)

# Use given Clang as a compiler.
set(CMAKE_CXX_COMPILER "${LLVM_TOOLS_BINARY_DIR}/clang++")
set(CMAKE_C_COMPILER "${LLVM_TOOLS_BINARY_DIR}/clang")

list(APPEND CMAKE_MODULE_PATH "${LLVM_CMAKE_DIR}")
# Use `add_llvm_...` functions.
include(AddLLVM)
# Set compiler flags.
include(HandleLLVMOptions)
# Use LLVM and Clang headers.
include_directories(${LLVM_INCLUDE_DIRS} ${CLANG_INCLUDE_DIRS})

# Run `clang-format` to each source for the given target.
# This is a phony target and always being executed.
# TODO: Find better solution.
function(add_clang_format_custom_target target)
    get_target_property(sources ${target} SOURCES)
    set(source_locations "")
    foreach(source ${sources})
        get_source_file_property(source_location ${source} LOCATION)
        list(APPEND source_locations ${source_location})
    endforeach()
    add_custom_target(${target}_clang_format
        COMMAND ${LLVM_TOOLS_BINARY_DIR}/clang-format -i ${source_locations}
        COMMENT "Format ${source_locations}"
        SOURCES ${sources})
    add_dependencies(${target} ${target}_clang_format)
endfunction()

# Disable `llvm_check_source_file_list` which requires all source files
# should be in a target of the `CMakeLists.txt` next to these files.
function(llvm_check_source_file_list)
endfunction(llvm_check_source_file_list)
