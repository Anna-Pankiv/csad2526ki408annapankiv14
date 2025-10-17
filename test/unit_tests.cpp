// unit_tests.cpp
// Simple, self-contained unit tests for math_operations::add
//
// Build:
//   g++ -std=c++11 unit_tests.cpp math_operations.cpp -o unit_tests
// Run:
//   ./unit_tests
//
// The tests use assert and will abort on failure. Successful run prints a confirmation.

#include <iostream>
#include <cassert>
#include "math_operations.h"

int main() {
    using math_ops::add;

    // Basic cases
    assert(add(0, 0) == 0);
    assert(add(2, 3) == 5);
    assert(add(-1, 1) == 0);
    assert(add(-5, -7) == -12);

    // Edge-ish cases
    assert(add(2147483647, 0) == 2147483647); // INT_MAX + 0
    assert(add(0, -2147483648) == -2147483648); // INT_MIN + 0

    std::cout << "All unit tests passed.\n";
    return 0;
}
