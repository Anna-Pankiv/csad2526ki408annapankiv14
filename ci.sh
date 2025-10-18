#!/usr/bin/env bash
# build.sh — configure, build and run tests for the project
set -euo pipefail

# Create and enter build directory
mkdir -p build
cd build

# Configure the project (adjust -DCMAKE_BUILD_TYPE if needed)
cmake ..

# Build the project
cmake --build .

# Run tests via CTest and show output on failure
ctest --output-on-failure

# Exit back to repo root (optional)
cd ..
