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
# Use same Xcode toolchain that builds these example targets.
if(CLANG_PLUGINS_XCODE_TOOLCHAIN)
    set(XCCONFIG_XCODE_TOOLCHAIN "TOOLCHAINS = ${CLANG_PLUGINS_XCODE_TOOLCHAIN}")
endif()
configure_file(Example.xcconfig.in
    # NOTE: This is intentionally create output in `CMAKE_CURRENT_SOURCE_DIR`
    # so that `Example.xcodeproj` can include this file from same directory.
    # See `examples/Example/Configurations/Config.xcconfig`.
    ${CMAKE_CURRENT_SOURCE_DIR}/Example/Configurations/Example.xcconfig
    @ONLY)
