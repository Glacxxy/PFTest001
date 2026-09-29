cmake_minimum_required(VERSION 3.22)

project(player_finder LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

set(MOD_ID "player_finder" CACHE STRING "LeviLauncher mod id")
set(MOD_NAME "Player Finder" CACHE STRING "LeviLauncher mod display name")
set(MOD_AUTHOR "Glacxxy" CACHE STRING "LeviLauncher mod author")
set(MOD_VERSION "0.1.0" CACHE STRING "LeviLauncher mod version")
set(MOD_LIBRARY_NAME "player_finder" CACHE STRING "Native library name")
set(MOD_MINECRAFT_VERSIONS "[\"1.21.*\"]" CACHE STRING "Minecraft version JSON array")

include(FetchContent)
FetchContent_Declare(
    preloader_android
    GIT_REPOSITORY https://github.com/LiteLDev/preloader-android.git
    GIT_TAG 0.2.2
    SOURCE_SUBDIR cmake/preloader-sdk
)
FetchContent_MakeAvailable(preloader_android)
FetchContent_GetProperties(preloader_android)
set(LEVI_PRELOADER_INCLUDE_DIR "${preloader_android_SOURCE_DIR}/include")

if(NOT ANDROID)
    message(STATUS "Android build is required for Player Finder")
    return()
endif()

if(NOT CMAKE_ANDROID_ARCH_ABI STREQUAL "arm64-v8a")
    message(FATAL_ERROR "Player Finder currently targets arm64-v8a only")
endif()

if(NOT TARGET preloader)
    add_subdirectory("${preloader_android_SOURCE_DIR}" "${CMAKE_BINARY_DIR}/_preloader_android")
endif()

add_library(${MOD_LIBRARY_NAME} SHARED src/PlayerFinder.cpp)

target_include_directories(${MOD_LIBRARY_NAME} PRIVATE "${LEVI_PRELOADER_INCLUDE_DIR}")
target_compile_options(${MOD_LIBRARY_NAME} PRIVATE -fvisibility=hidden -fvisibility-inlines-hidden)
target_link_options(${MOD_LIBRARY_NAME} PRIVATE "-Wl,-z,max-page-size=16384")

find_library(log-lib log REQUIRED)
target_link_libraries(${MOD_LIBRARY_NAME} PRIVATE preloader ${log-lib} dl)

set(MANIFEST "${CMAKE_CURRENT_BINARY_DIR}/manifest.json")
file(GENERATE OUTPUT "${MANIFEST}" CONTENT "{\n  \"type\": \"preload-native\",\n  \"name\": \"${MOD_NAME}\",\n  \"author\": \"${MOD_AUTHOR}\",\n  \"version\": \"${MOD_VERSION}\",\n  \"entry\": \"lib${MOD_LIBRARY_NAME}.so\",\n  \"minecraft_versions\": ${MOD_MINECRAFT_VERSIONS}\n}\n")

set(PACKAGE_ROOT "${CMAKE_CURRENT_BINARY_DIR}/package/${MOD_ID}")
set(PACKAGE_FILE "${CMAKE_CURRENT_BINARY_DIR}/${MOD_ID}-${MOD_VERSION}-${CMAKE_ANDROID_ARCH_ABI}.levipack")

add_custom_target(levi_package
    COMMAND "${CMAKE_COMMAND}" -E rm -rf "${CMAKE_CURRENT_BINARY_DIR}/package"
    COMMAND "${CMAKE_COMMAND}" -E make_directory "${PACKAGE_ROOT}"
    COMMAND "${CMAKE_COMMAND}" -E copy "$<TARGET_FILE:${MOD_LIBRARY_NAME}>" "${PACKAGE_ROOT}/lib${MOD_LIBRARY_NAME}.so"
    COMMAND "${CMAKE_COMMAND}" -E copy "${MANIFEST}" "${PACKAGE_ROOT}/manifest.json"
    COMMAND "${CMAKE_COMMAND}" -E chdir "${CMAKE_CURRENT_BINARY_DIR}/package" "${CMAKE_COMMAND}" -E tar "cf" "${PACKAGE_FILE}" --format=zip "${MOD_ID}"
    DEPENDS ${MOD_LIBRARY_NAME}
    COMMENT "Packaging ${MOD_ID}.levipack"
    VERBATIM
)
