#include <gtest/gtest.h>

#include "add.h"

TEST(BasicAddition, AddsTwoNumbers) {
    EXPECT_EQ(add(2, 3), 5);
}
