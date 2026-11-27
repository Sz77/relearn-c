#include "exitcode.h"
#include "unity.h"

#include <limits.h>
#include <stdlib.h>

void setUp(void)
{
}

void tearDown(void)
{
}

/* ---- exitcode_wrap ------------------------------------------------------ */

static void test_wrap_zero_is_zero(void)
{
    TEST_ASSERT_EQUAL_INT(0, exitcode_wrap(0));
}

static void test_wrap_one_is_one(void)
{
    TEST_ASSERT_EQUAL_INT(1, exitcode_wrap(1));
}

static void test_wrap_small_values_unchanged(void)
{
    TEST_ASSERT_EQUAL_INT(2, exitcode_wrap(2));
    TEST_ASSERT_EQUAL_INT(42, exitcode_wrap(42));
    TEST_ASSERT_EQUAL_INT(127, exitcode_wrap(127));
    TEST_ASSERT_EQUAL_INT(128, exitcode_wrap(128));
}

static void test_wrap_255_is_the_largest_unchanged_value(void)
{
    TEST_ASSERT_EQUAL_INT(255, exitcode_wrap(255));
}

static void test_wrap_256_becomes_zero(void)
{
    TEST_ASSERT_EQUAL_INT_MESSAGE(0, exitcode_wrap(256), "only the low 8 bits survive");
}

static void test_wrap_257_becomes_one(void)
{
    TEST_ASSERT_EQUAL_INT(1, exitcode_wrap(257));
}

static void test_wrap_300_becomes_44(void)
{
    TEST_ASSERT_EQUAL_INT(44, exitcode_wrap(300));
}

static void test_wrap_multiples_of_256_become_zero(void)
{
    TEST_ASSERT_EQUAL_INT(0, exitcode_wrap(512));
    TEST_ASSERT_EQUAL_INT(0, exitcode_wrap(256 * 1000));
    TEST_ASSERT_EQUAL_INT(0, exitcode_wrap(-512));
}

static void test_wrap_minus_one_becomes_255(void)
{
    TEST_ASSERT_EQUAL_INT_MESSAGE(255, exitcode_wrap(-1), "result must never be negative");
}

static void test_wrap_minus_255_becomes_one(void)
{
    TEST_ASSERT_EQUAL_INT(1, exitcode_wrap(-255));
}

static void test_wrap_minus_256_becomes_zero(void)
{
    TEST_ASSERT_EQUAL_INT(0, exitcode_wrap(-256));
}

static void test_wrap_minus_257_becomes_255(void)
{
    TEST_ASSERT_EQUAL_INT(255, exitcode_wrap(-257));
}

static void test_wrap_int_max_becomes_255(void)
{
    /* INT_MAX = 2^31 - 1, whose low 8 bits are all ones. Adding anything to
     * INT_MAX before reducing it is signed overflow (UBSan will stop you). */
    TEST_ASSERT_EQUAL_INT(255, exitcode_wrap(INT_MAX));
}

static void test_wrap_int_max_minus_one_becomes_254(void)
{
    TEST_ASSERT_EQUAL_INT(254, exitcode_wrap(INT_MAX - 1));
}

static void test_wrap_int_min_becomes_zero(void)
{
    /* INT_MIN = -2^31. Negating it (for example with abs or unary minus)
     * is signed overflow: undefined behavior. */
    TEST_ASSERT_EQUAL_INT(0, exitcode_wrap(INT_MIN));
}

static void test_wrap_int_min_plus_one_becomes_one(void)
{
    TEST_ASSERT_EQUAL_INT(1, exitcode_wrap(INT_MIN + 1));
}

static void test_wrap_result_always_in_range(void)
{
    for (int v = -1000; v <= 1000; v++) {
        int got = exitcode_wrap(v);
        TEST_ASSERT_TRUE_MESSAGE(got >= 0 && got <= 255, "result must be in 0..255");
        TEST_ASSERT_EQUAL_INT_MESSAGE(((v % 256) + 256) % 256, got, "wrong value in -1000..1000");
    }
}

/* ---- exitcode_is_success ------------------------------------------------ */

static void test_is_success_zero(void)
{
    TEST_ASSERT_TRUE(exitcode_is_success(0));
}

static void test_is_success_exit_success_macro(void)
{
    TEST_ASSERT_TRUE(exitcode_is_success(EXIT_SUCCESS));
}

static void test_is_success_rejects_one(void)
{
    TEST_ASSERT_FALSE(exitcode_is_success(1));
}

static void test_is_success_rejects_exit_failure_macro(void)
{
    TEST_ASSERT_FALSE(exitcode_is_success(EXIT_FAILURE));
}

static void test_is_success_rejects_minus_one(void)
{
    TEST_ASSERT_FALSE(exitcode_is_success(-1));
}

static void test_is_success_accepts_256(void)
{
    TEST_ASSERT_TRUE_MESSAGE(exitcode_is_success(256), "return 256 shows up as $? == 0");
}

static void test_is_success_accepts_minus_256(void)
{
    TEST_ASSERT_TRUE(exitcode_is_success(-256));
}

static void test_is_success_rejects_255(void)
{
    TEST_ASSERT_FALSE(exitcode_is_success(255));
}

static void test_is_success_rejects_int_max(void)
{
    TEST_ASSERT_FALSE(exitcode_is_success(INT_MAX));
}

static void test_is_success_accepts_int_min(void)
{
    TEST_ASSERT_TRUE(exitcode_is_success(INT_MIN));
}

/* ---- exitcode_name ------------------------------------------------------ */

static void test_name_zero_is_exit_success(void)
{
    TEST_ASSERT_EQUAL_STRING("EXIT_SUCCESS", exitcode_name(0));
}

static void test_name_one_is_exit_failure(void)
{
    TEST_ASSERT_EQUAL_STRING("EXIT_FAILURE", exitcode_name(1));
}

static void test_name_matches_macros(void)
{
    TEST_ASSERT_EQUAL_STRING("EXIT_SUCCESS", exitcode_name(EXIT_SUCCESS));
    TEST_ASSERT_EQUAL_STRING("EXIT_FAILURE", exitcode_name(EXIT_FAILURE));
}

static void test_name_two_is_other(void)
{
    TEST_ASSERT_EQUAL_STRING("other", exitcode_name(2));
}

static void test_name_255_is_other(void)
{
    TEST_ASSERT_EQUAL_STRING("other", exitcode_name(255));
}

static void test_name_minus_one_is_other(void)
{
    TEST_ASSERT_EQUAL_STRING("other", exitcode_name(-1));
}

static void test_name_uses_wrapped_status_256(void)
{
    TEST_ASSERT_EQUAL_STRING_MESSAGE("EXIT_SUCCESS", exitcode_name(256), "name the WRAPPED status");
}

static void test_name_uses_wrapped_status_257(void)
{
    TEST_ASSERT_EQUAL_STRING_MESSAGE("EXIT_FAILURE", exitcode_name(257), "name the WRAPPED status");
}

static void test_name_uses_wrapped_status_minus_255(void)
{
    TEST_ASSERT_EQUAL_STRING("EXIT_FAILURE", exitcode_name(-255));
}

static void test_name_int_max_is_other(void)
{
    TEST_ASSERT_EQUAL_STRING("other", exitcode_name(INT_MAX));
}

static void test_name_int_min_is_exit_success(void)
{
    TEST_ASSERT_EQUAL_STRING("EXIT_SUCCESS", exitcode_name(INT_MIN));
}

static void test_name_never_returns_null(void)
{
    for (int v = -600; v <= 600; v++) {
        TEST_ASSERT_NOT_NULL(exitcode_name(v));
    }
}

static void test_name_returns_same_static_string(void)
{
    /* The result is a string literal, not a fresh allocation: calling twice
     * gives text that compares equal, and the caller never frees it. Any
     * malloc in the solution would show up here as a leak. */
    const char *first = exitcode_name(3);
    const char *second = exitcode_name(4);
    TEST_ASSERT_EQUAL_STRING(first, second);
}

int main(void)
{
    UNITY_BEGIN();
    RUN_TEST(test_wrap_zero_is_zero);
    RUN_TEST(test_wrap_one_is_one);
    RUN_TEST(test_wrap_small_values_unchanged);
    RUN_TEST(test_wrap_255_is_the_largest_unchanged_value);
    RUN_TEST(test_wrap_256_becomes_zero);
    RUN_TEST(test_wrap_257_becomes_one);
    RUN_TEST(test_wrap_300_becomes_44);
    RUN_TEST(test_wrap_multiples_of_256_become_zero);
    RUN_TEST(test_wrap_minus_one_becomes_255);
    RUN_TEST(test_wrap_minus_255_becomes_one);
    RUN_TEST(test_wrap_minus_256_becomes_zero);
    RUN_TEST(test_wrap_minus_257_becomes_255);
    RUN_TEST(test_wrap_int_max_becomes_255);
    RUN_TEST(test_wrap_int_max_minus_one_becomes_254);
    RUN_TEST(test_wrap_int_min_becomes_zero);
    RUN_TEST(test_wrap_int_min_plus_one_becomes_one);
    RUN_TEST(test_wrap_result_always_in_range);
    RUN_TEST(test_is_success_zero);
    RUN_TEST(test_is_success_exit_success_macro);
    RUN_TEST(test_is_success_rejects_one);
    RUN_TEST(test_is_success_rejects_exit_failure_macro);
    RUN_TEST(test_is_success_rejects_minus_one);
    RUN_TEST(test_is_success_accepts_256);
    RUN_TEST(test_is_success_accepts_minus_256);
    RUN_TEST(test_is_success_rejects_255);
    RUN_TEST(test_is_success_rejects_int_max);
    RUN_TEST(test_is_success_accepts_int_min);
    RUN_TEST(test_name_zero_is_exit_success);
    RUN_TEST(test_name_one_is_exit_failure);
    RUN_TEST(test_name_matches_macros);
    RUN_TEST(test_name_two_is_other);
    RUN_TEST(test_name_255_is_other);
    RUN_TEST(test_name_minus_one_is_other);
    RUN_TEST(test_name_uses_wrapped_status_256);
    RUN_TEST(test_name_uses_wrapped_status_257);
    RUN_TEST(test_name_uses_wrapped_status_minus_255);
    RUN_TEST(test_name_int_max_is_other);
    RUN_TEST(test_name_int_min_is_exit_success);
    RUN_TEST(test_name_never_returns_null);
    RUN_TEST(test_name_returns_same_static_string);
    return UNITY_END();
}
