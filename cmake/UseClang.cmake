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
    foreach(source IN LISTS sources)
        get_source_file_property(source_location ${source} LOCATION)
        list(APPEND source_locations ${source_location})
    endforeach()
    add_custom_target(${target}_clang_format
        COMMAND ${LLVM_TOOLS_BINARY_DIR}/clang-format -i ${source_locations}
        COMMENT "Format ${source_locations}"
        SOURCES ${sources})
    add_dependencies(${target} ${target}_clang_format)
endfunction()

# Add symbol to the list of global symbols names for the target
# that will remain as global symbols in the output file.
function(append_target_exported_symbols target)
    # Instead of using `LLVM_EXPORTED_SYMBOL_FILE`, it's only for Darwin though,
    # Use `-exported_symbol` instead, to make things easier.
    # See `ld(1)`.
    # See also `add_llvm_symbol_exports` and `LLVM_EXPORTED_SYMBOL_FILE` in `AddLLVM.cmake`.
    set(link_flags_string "")
    foreach(symbol IN LISTS ARGN)
        string(APPEND link_flags_string " -Wl,-exported_symbol," ${symbol})
    endforeach()
    set_property(TARGET ${target}
        APPEND_STRING PROPERTY LINK_FLAGS ${link_flags_string})
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
    # TODO: Ensure which library is really needed.
    # Minimum required Clang libraries, which are not included in Xcode default toolchain.
    target_link_libraries(${name}
        PRIVATE
        clangFrontend)
    # No dynamic link libraries, remove unnecessary rpath.
    set_target_properties(${name} PROPERTIES
        BUILD_WITH_INSTALL_RPATH FALSE)
    # See `clang/Frontend/FrontendPluginRegistry.h`, `llvm/Support/Registry.h`.
    append_target_exported_symbols(${name}
        "__ZN4llvm8Registry*")
    add_clang_format_custom_target(${name})
endfunction()

# Create a Clang analyzer checker target
function(add_clang_analyzer_checker name)
    add_llvm_loadable_module(${name}
        PLUGIN_TOOL clang
        ${ARGN})
    # TODO: Ensure which library is really needed.
    # Minimum required Clang libraries, which are not included in Xcode default toolchain.
    target_link_libraries(${name}
        PRIVATE
        clangStaticAnalyzerCore)
    # No dynamic link libraries, remove unnecessary rpath.
    set_target_properties(${name} PROPERTIES
        BUILD_WITH_INSTALL_RPATH FALSE)
    # See `clang/StaticAnalyzer/Core/CheckerRegistry.h`.
    append_target_exported_symbols(${name}
        "_clang_registerCheckers"
        "_clang_analyzerAPIVersionString")
    add_clang_format_custom_target(${name})
endfunction()
