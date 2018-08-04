# Name of Xcode toolchain that is used by the example Xcode project.
# This is not for building these example Clang tool, plugin, or analyzer checker
# but for using these plugin or analyzer checker.
# Default to using the Xcode default toolchain.
set(CLANG_PLUGINS_EXAMPLES_XCODE_TOOLCHAIN ""
    CACHE STRING "Xcode toolchain name that example Xcode project uses")


# Example Clang tool
add_clang_tool(example_tool
    example_tool.cpp)

# Example Clang plugin
add_clang_plugin(example_plugin
    example_plugin.cpp)

# Example Clang analyzer cheker
add_clang_plugin(example_checker
    example_checker.cpp)


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
