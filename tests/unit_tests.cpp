#include <gtest/gtest.h>
#include "math_operations.h"
#include <limits>

TEST(MathOperationsAdd, BasicCases) {
    using math_ops::add;

    EXPECT_EQ(add(0, 0), 0);
    EXPECT_EQ(add(2, 3), 5);
    EXPECT_EQ(add(-1, 1), 0);
    EXPECT_EQ(add(-5, -7), -12);
}

TEST(MathOperationsAdd, EdgeCases) {
    using math_ops::add;
    const int int_max = std::numeric_limits<int>::max();
    const int int_min = std::numeric_limits<int>::min();

    EXPECT_EQ(add(int_max, 0), int_max); // INT_MAX + 0
    EXPECT_EQ(add(0, int_min), int_min); // INT_MIN + 0
}
