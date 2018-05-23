cmake_minimum_required(VERSION 3.10)

project(XcodeToolchain)

include(ExternalProject)

set(XCODE_TOOLCHAIN_APPLE_SWIFT_GIT_TAG "origin/stable"
    CACHE STRING "Branch name to be checked out for each Swift repositories to build Xcode toolchain.")

set(XCODE_TOOLCHAIN_NAME "Custom"
    CACHE STRING "A name of Xcode toolchain")

# RFC1034 identifier should start with alphabets, then only contain alphabets, numbers, or dash
# then end with alphabets or numbers.
# See <https://tools.ietf.org/html/rfc1034>.
string(REGEX REPLACE "(^[^a-zA-Z]|[^a-zA-Z0-9-]|[^a-zA-Z0-9]$)" "" XCODE_TOOLCHAIN_RFC1034_IDENTIFIER ${XCODE_TOOLCHAIN_NAME})

set(XCODE_TOOLCHAIN_BUNDLE_IDENTIFIER "toolchain.${XCODE_TOOLCHAIN_RFC1034_IDENTIFIER}"
    CACHE STRING "A name of Xcode toolchain")
set(XCODE_TOOLCHAIN_BUNDLE_VERSION "0.1.0"
    CACHE STRING "A version of Xcode toolchain bundle")
set(XCODE_TOOLCHAIN_BUNDLE_DISPLAY_NAME ${XCODE_TOOLCHAIN_NAME}
    CACHE STRING "A display name of Xcode toolchain")
set(XCODE_TOOLCHAIN_BUNDLE_REPORT_PROBLEM_URL "http://"
    CACHE STRING "A URL for reporting problems of Xcode toolchain")

set(XCODE_TOOLCHAIN_BUNDLE_NAME "${XCODE_TOOLCHAIN_RFC1034_IDENTIFIER}.xctoolchain")

set(XCODE_TOOLCHAIN_BUNDLE_INSTALL_PREFIX "$ENV{HOME}/Library/Developer/Toolchains"
    CACHE PATH "A path to install Xcode toolchain bundle.")

set(XCODE_TOOLCHAIN_BUNDLE_COMPATIBILITY_VERSION 2)
set(XCODE_TOOLCHAIN_BUNDLE_COMPATIBILITY_VERSION_DISPLAY_STRING "Xcode 8.0")
string(TIMESTAMP XCODE_TOOLCHAIN_BUNDLE_CREATED_DATE "%a %b %d %H:%M:%S GMT %Y" UTC)

# Each `<SOURCE_DIR>`, `<SOURCE_SUBDIR>`, `<BINARY_DIR>`, `<INSTALL_DIR>`, and `<TMP_DIR>`
# used for `ExternalProject_Add` is repalced with their corresponding property values.
# See at the bottom of `ExternalProject_Add_Step` section at <https://cmake.org/cmake/help/v3.10/module/ExternalProject.html>.

# This external project is download only.
# Clang is built as a part of LLVM.
ExternalProject_Add(apple_clang
    GIT_REPOSITORY "https://github.com/apple/swift-clang.git"
    GIT_TAG ${XCODE_TOOLCHAIN_APPLE_SWIFT_GIT_TAG}
    GIT_SHALLOW TRUE
    GIT_PROGRESS TRUE
    # Do not configure, build, and install.
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND "")

# This external project is download only.
# compiler-rt is built as a part of LLVM.
ExternalProject_Add(apple_compiler_rt
    GIT_REPOSITORY "https://github.com/apple/swift-compiler-rt.git"
    GIT_TAG ${XCODE_TOOLCHAIN_APPLE_SWIFT_GIT_TAG}
    GIT_SHALLOW TRUE
    GIT_PROGRESS TRUE
    # Do not configure, build, and install.
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND "")

# This `<INSTALL_DIR>` is replaced to the corresponding property value.
set(XCODE_TOOLCHAIN_BUNDLE_PATH <INSTALL_DIR>/${XCODE_TOOLCHAIN_BUNDLE_NAME})
set(XCODE_TOOLCHAIN_BUNDLE_INFO_PLIST_PATH ${XCODE_TOOLCHAIN_BUNDLE_PATH}/Info.plist)

ExternalProject_Add(apple_llvm
    GIT_REPOSITORY "https://github.com/apple/swift-llvm.git"
    GIT_TAG ${XCODE_TOOLCHAIN_APPLE_SWIFT_GIT_TAG}
    GIT_SHALLOW TRUE
    GIT_PROGRESS TRUE
    # TODO: See the other args like `-DCMAKE_C_FLAGS`, `-DCMAKE_CXX_FLAGS`.
    CMAKE_ARGS -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_INSTALL_PREFIX=${XCODE_TOOLCHAIN_BUNDLE_PATH}/usr)

# A custom step to create a symbolic link to Clang source code in LLVM source tree.
ExternalProject_Get_Property(apple_clang SOURCE_DIR)
ExternalProject_Add_Step(apple_llvm add_clang_to_llvm
    # These `<SOURCE_DIR>` are replaced to the corresponding property value.
    COMMAND ${CMAKE_COMMAND} -E create_symlink ${SOURCE_DIR} <SOURCE_DIR>/tools/clang
    BYPRODUCTS <SOURCE_DIR>/tools/clang
    # Checking out Git branch is `upate` step.
    DEPENDEES update
    DEPENDERS configure)
ExternalProject_Add_StepDependencies(apple_llvm add_clang_to_llvm apple_clang)

# A custom step to create a symbolic link to compiler-rt source code in LLVM source tree.
ExternalProject_Get_Property(apple_compiler_rt SOURCE_DIR)
ExternalProject_Add_Step(apple_llvm add_compiler_rt_to_llvm
    # These `<SOURCE_DIR>` are replaced to the corresponding property value.
    COMMAND ${CMAKE_COMMAND} -E create_symlink ${SOURCE_DIR} <SOURCE_DIR>/projects/compiler-rt
    BYPRODUCTS <SOURCE_DIR>/projects/compiler-rt
    # Checking out Git branch is `upate` step.
    DEPENDEES update
    DEPENDERS configure)
ExternalProject_Add_StepDependencies(apple_llvm add_compiler_rt_to_llvm apple_compiler_rt)

# A custom step to create `Info.plist` after installing LLVM to `CMAKE_INSTALL_PREFIX`.
set(XCODE_TOOLCHAIN_BUNDLE_PLIST_BUDDY_BIN /usr/libexec/PlistBuddy)
ExternalProject_Add_Step(apple_llvm create_bundle_info_plist
    # We need to remove existing file, otherwise `PlistBuddy` complains that the same key already exists.
    COMMAND ${CMAKE_COMMAND} -E remove ${XCODE_TOOLCHAIN_BUNDLE_INFO_PLIST_PATH}
    # Use `PlistBuddy` to create `Info.plist`.
    # TODO: Not all fields are requried.
    COMMAND ${XCODE_TOOLCHAIN_BUNDLE_PLIST_BUDDY_BIN} -c "Add DisplayName string '${XCODE_TOOLCHAIN_BUNDLE_DISPLAY_NAME}'" ${XCODE_TOOLCHAIN_BUNDLE_INFO_PLIST_PATH}
    COMMAND ${XCODE_TOOLCHAIN_BUNDLE_PLIST_BUDDY_BIN} -c "Add ShortDisplayName string '${XCODE_TOOLCHAIN_BUNDLE_DISPLAY_NAME}'" ${XCODE_TOOLCHAIN_BUNDLE_INFO_PLIST_PATH}
    COMMAND ${XCODE_TOOLCHAIN_BUNDLE_PLIST_BUDDY_BIN} -c "Add CreatedDate date '${XCODE_TOOLCHAIN_BUNDLE_CREATED_DATE}'" ${XCODE_TOOLCHAIN_BUNDLE_INFO_PLIST_PATH}
    COMMAND ${XCODE_TOOLCHAIN_BUNDLE_PLIST_BUDDY_BIN} -c "Add CompatibilityVersion integer ${XCODE_TOOLCHAIN_BUNDLE_COMPATIBILITY_VERSION}" ${XCODE_TOOLCHAIN_BUNDLE_INFO_PLIST_PATH}
    COMMAND ${XCODE_TOOLCHAIN_BUNDLE_PLIST_BUDDY_BIN} -c "Add CompatibilityVersionDisplayString string '${XCODE_TOOLCHAIN_BUNDLE_COMPATIBILITY_VERSION_DISPLAY_STRING}'" ${XCODE_TOOLCHAIN_BUNDLE_INFO_PLIST_PATH}
    COMMAND ${XCODE_TOOLCHAIN_BUNDLE_PLIST_BUDDY_BIN} -c "Add Version string '${XCODE_TOOLCHAIN_BUNDLE_VERSION}'" ${XCODE_TOOLCHAIN_BUNDLE_INFO_PLIST_PATH}
    COMMAND ${XCODE_TOOLCHAIN_BUNDLE_PLIST_BUDDY_BIN} -c "Add CFBundleIdentifier string '${XCODE_TOOLCHAIN_BUNDLE_IDENTIFIER}'" ${XCODE_TOOLCHAIN_BUNDLE_INFO_PLIST_PATH}
    COMMAND ${XCODE_TOOLCHAIN_BUNDLE_PLIST_BUDDY_BIN} -c "Add ReportProblemURL string '${XCODE_TOOLCHAIN_BUNDLE_REPORT_PROBLEM_URL}'" ${XCODE_TOOLCHAIN_BUNDLE_INFO_PLIST_PATH}
    COMMAND ${XCODE_TOOLCHAIN_BUNDLE_PLIST_BUDDY_BIN} -c "Add Aliases array" ${XCODE_TOOLCHAIN_BUNDLE_INFO_PLIST_PATH}
    COMMAND ${XCODE_TOOLCHAIN_BUNDLE_PLIST_BUDDY_BIN} -c "Add Aliases:0 string '${XCODE_TOOLCHAIN_NAME}'" ${XCODE_TOOLCHAIN_BUNDLE_INFO_PLIST_PATH}
    BYPRODUCTS ${XCODE_TOOLCHAIN_BUNDLE_INFO_PLIST_PATH}
    DEPENDEES install)

# A custom step to create a symbolic link of Xcode toolchain to `~/Library/Developer/Toolchains`
set(XCODE_TOOLCHAIN_BUNDLE_INSTALL_PATH ${XCODE_TOOLCHAIN_BUNDLE_INSTALL_PREFIX}/${XCODE_TOOLCHAIN_BUNDLE_NAME})
ExternalProject_Add_Step(apple_llvm symlink_xcode_toolchain
    COMMAND ${CMAKE_COMMAND} -E create_symlink ${XCODE_TOOLCHAIN_BUNDLE_PATH} ${XCODE_TOOLCHAIN_BUNDLE_INSTALL_PATH}
    BYPRODUCTS ${XCODE_TOOLCHAIN_BUNDLE_INSTALL_PATH}
    DEPENDEES create_bundle_info_plist
    # This is an optional step and exclude from default targets.
    EXCLUDE_FROM_MAIN TRUE)
ExternalProject_Add_StepTargets(apple_llvm symlink_xcode_toolchain)

# A custom step to create a distribution archive of Xcode toolchain
set(XCODE_TOOLCHAIN_BUNDLE_PLIST_DITTO_BIN /usr/bin/ditto)
set(XCODE_TOOLCHAIN_BUNDLE_DISTRIBUTION_ARCHIVE_PATH ${XCODE_TOOLCHAIN_BUNDLE_PATH}.zip)
ExternalProject_Add_Step(apple_llvm create_xcode_toolchain_distribution_archive
    COMMAND ${XCODE_TOOLCHAIN_BUNDLE_PLIST_DITTO_BIN} -c -k --keepParent ${XCODE_TOOLCHAIN_BUNDLE_PATH} ${XCODE_TOOLCHAIN_BUNDLE_DISTRIBUTION_ARCHIVE_PATH}
    BYPRODUCTS ${XCODE_TOOLCHAIN_BUNDLE_DISTRIBUTION_ARCHIVE_PATH}
    DEPENDEES create_bundle_info_plist
    # This is an optional step and exclude from default targets.
    EXCLUDE_FROM_MAIN TRUE)
ExternalProject_Add_StepTargets(apple_llvm create_xcode_toolchain_distribution_archive)
