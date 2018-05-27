# Common configuration script for using Clang

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

# Disable `llvm_check_source_file_list` which requires all source files
# should be in a target of the `CMakeLists.txt` next to these files.
function(llvm_check_source_file_list)
endfunction()

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

# Create a Clang tool target
function(add_clang_tool name)
    add_llvm_executable(${name} ${ARGN})
    target_link_libraries(${name}
        clangTooling)
    add_clang_format_custom_target(${name})
endfunction()

# Create a Clang plugin target
function(add_clang_plugin name)
    add_llvm_loadable_module(${name}
        PLUGIN_TOOL clang
        ${ARGN})
    add_clang_format_custom_target(${name})
endfunction()
