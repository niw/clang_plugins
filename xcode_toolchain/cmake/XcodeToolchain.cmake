# A set of helper scripts for Xcode toolchain

# find_xcode_toolchain_path(<VAR> [<name>])
# Set <VAR> to path to the Xcode toolchain of <name>.
# <name> is default to `com.apple.dt.toolchain.XcodeDefault`.
# If Xcode toolchain <name> is not found, the path to default toolchain path
# because of `xcrun` behavior.
function(find_xcode_toolchain_path var)
    list(LENGTH ARGN argn_length)
    if(argn_length GREATER 0)
        list(GET ARGN 0 name)
    else()
        set(name "com.apple.dt.toolchain.XcodeDefault")
    endif()

    execute_process(
        COMMAND /usr/bin/xcrun --toolchain ${name} --find clang
        OUTPUT_VARIABLE clang_path
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_QUIET)

    get_filename_component(clang_dir_path ${clang_path} DIRECTORY)
    get_filename_component(xcode_toolchain_path ${clang_dir_path} DIRECTORY)

    set(${var} ${xcode_toolchain_path} PARENT_SCOPE)
endfunction()
