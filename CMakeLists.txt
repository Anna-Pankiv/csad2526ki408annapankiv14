cmake_minimum_required(VERSION 3.14)
project(HelloWorld LANGUAGES CXX)

# Use C++11 (adjust if you want a newer standard)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Main executable (adjust sources as needed)
add_executable(hello main.cpp math_operations.cpp)

# -----------------------------
# GoogleTest integration
# -----------------------------
# This uses CMake's FetchContent to download and make GoogleTest available
# at configure time. Requires CMake >= 3.14.
include(FetchContent)

# Optionally force shared CRT on Windows to match parent project settings
# (uncomment if necessary)
# set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)

FetchContent_Declare(
  googletest
  URL https://github.com/google/googletest/archive/refs/tags/v1.14.0.zip
)

# Prevent overriding compiler/linker settings of the parent project
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)

# Download and add googletest targets (GTest::gtest, GTest::gmock, etc.)
FetchContent_MakeAvailable(googletest)

# Enable CTest support
enable_testing()

# Unit test target — include the implementation file(s) needed by tests
add_executable(unit_tests unit_tests.cpp math_operations.cpp)

# Link against GoogleTest and use its main() helper
target_link_libraries(unit_tests PRIVATE GTest::gtest_main)

# Make sure tests can include headers from the project root
target_include_directories(unit_tests PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})

# Register the test with CTest
add_test(NAME unit_tests COMMAND unit_tests)

# Optional: control test build via option
option(BUILD_TESTS "Build unit tests" ON)
if(NOT BUILD_TESTS)
  # If tests are disabled, remove the test target and disable adding tests
  remove_executable(unit_tests)
  remove_test(unit_tests)
endif()

# Helpful build/run instructions (comments):
# mkdir build && cd build
# cmake .. -DCMAKE_BUILD_TYPE=Release
# cmake --build . -- -j
# ctest --output-on-failure
