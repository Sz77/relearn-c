/*
 * ex02-exitcode: see README.md and exitcode.h in this folder.
 *
 * This file must NOT define main(): the test program provides its own main
 * and links against the functions you write here.
 */
#include "exitcode.h"

#include <stdlib.h>

int exitcode_wrap(int main_return)
{
    (void)main_return;
    /* TODO */
    return -1;
}

bool exitcode_is_success(int main_return)
{
    (void)main_return;
    /* TODO */
    return false;
}

const char *exitcode_name(int main_return)
{
    (void)main_return;
    /* TODO */
    return "";
}
