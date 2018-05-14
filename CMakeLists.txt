cmake_minimum_required(VERSION 3.10)

project(clang_plugins)

# Let CMake to find LLVM and Clang modules.
# Give `-DCMAKE_PREFIX_PATH` or `-DLLVM_DIR` and `-DCLANG_DIR`.
# See <https://cmake.org/cmake/help/v3.11/command/find_package.html>
find_package(LLVM REQUIRED CONFIG)
find_package(CLANG REQUIRED CONFIG)

# Use given `clang` toolchain.
set(CMAKE_CXX_COMPILER "${LLVM_TOOLS_BINARY_DIR}/clang++")
set(CMAKE_C_COMPILER "${LLVM_TOOLS_BINARY_DIR}/clang")

list(APPEND CMAKE_MODULE_PATH "${LLVM_CMAKE_DIR}")
# Use `add_llvm_...` functions.
include(AddLLVM)
# Set compiler flags.
include(HandleLLVMOptions)
# Use LLVM and clang headers.
include_directories(${LLVM_INCLUDE_DIRS} ${CLANG_INCLUDE_DIRS})

# Run clang-format to each source for the given target.
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
endfunction(add_clang_format_custom_target)

# Disable `llvm_check_source_file_list` which requires all source files
# should be in a target of the `CMakeLists.txt` next to these files.
function(llvm_check_source_file_list)
endfunction(llvm_check_source_file_list)
