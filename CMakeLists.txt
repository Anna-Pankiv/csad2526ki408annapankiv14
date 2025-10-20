cmake_minimum_required(VERSION 3.14)
project(HelloWorld LANGUAGES CXX)

# -----------------------------
# Compiler settings
# -----------------------------
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# -----------------------------
# Main executable
# -----------------------------
add_executable(hello
    main.cpp
    math_operations.cpp
)

# -----------------------------
# GoogleTest integration
# -----------------------------
include(FetchContent)

FetchContent_Declare(
  googletest
  URL https://github.com/google/googletest/archive/refs/tags/v1.14.0.zip
)

set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(googletest)

enable_testing()

# -----------------------------
# Unit tests
# -----------------------------
# Файл тепер у tests/unit_tests.cpp
add_executable(unit_tests
    tests/unit_tests.cpp
    math_operations.cpp
)

target_link_libraries(unit_tests PRIVATE GTest::gtest_main)
target_include_directories(unit_tests PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})

add_test(NAME unit_tests COMMAND unit_tests)

# -----------------------------
# Optional: toggle test build
# -----------------------------
option(BUILD_TESTS "Build unit tests" ON)
if(NOT BUILD_TESTS)
  message(STATUS "Unit tests are disabled.")
  remove_executable(unit_tests)
  unset(unit_tests CACHE)
endif()
