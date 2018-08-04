# Name of Xcode toolchain that is used by the example Xcode project.
# This is not for building these example Clang tool, plugin, or analyzer checker
# but for using these plugin or analyzer checker.
# Default to using the Xcode default toolchain.
set(CLANG_PLUGINS_EXAMPLES_XCODE_TOOLCHAIN ""
    CACHE STRING "Xcode toolchain name that example Xcode project uses")

# Clang version that is used by the example Xcode project.
# This is used for Clang analyzer checker's `clang_analyzerAPIVersionString`.
# In case using example Clang analyzer checker in the different Xcode, like the beta version of it,
# set appropriate version. For example, `"10.0.0"` for Xcode 10.0.
# Default to the Clang version that given Xcode toolchain is using.
set(CLANG_PLUGINS_EXAMPLES_CLANG_VERSION ""
    CACHE STRING "Clang version that example Xcode project uses")
if(NOT CLANG_PLUGINS_EXAMPLES_CLANG_VERSION)
    find_xcode_toolchain_clang_path(CLANG_PLUGINS_EXAMPLES_CLANG_PATH ${CLANG_PLUGINS_EXAMPLES_XCODE_TOOLCHAIN})
    get_clang_version(CLANG_PLUGINS_EXAMPLES_CLANG_VERSION ${CLANG_PLUGINS_EXAMPLES_CLANG_PATH})
endif()


# Example Clang tool
add_clang_tool(example_tool
    example_tool.cpp)

# Example Clang plugin
add_clang_plugin(example_plugin
    example_plugin.cpp)

# Example Clang analyzer cheker
clang_analyzer_checker(example_checker
    example_checker.cpp)


# Create `configure.h`.
configure_file(configure.h.in
    ${CMAKE_CURRENT_SOURCE_DIR}/configure.h
    @ONLY)

# Create xcconfig for Xcode Example project.
if(CLANG_PLUGINS_EXAMPLES_XCODE_TOOLCHAIN)
    set(XCCONFIG_XCODE_TOOLCHAIN "TOOLCHAINS = ${CLANG_PLUGINS_EXAMPLES_XCODE_TOOLCHAIN}")
endif()
configure_file(Example.xcconfig.in
    # NOTE: This is intentionally create output in `CMAKE_CURRENT_SOURCE_DIR`
    # so that `Example.xcodeproj` can include this file from same directory.
    # See `examples/Example/Configurations/Config.xcconfig`.
    ${CMAKE_CURRENT_SOURCE_DIR}/Example/Configurations/Example.xcconfig
    @ONLY)
