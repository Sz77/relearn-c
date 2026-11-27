/*
 * exitcode.h: what the shell really sees when main returns.
 *
 * Do not change this file. The tests include it, and your exitcode.c must
 * define every function declared here.
 */
#ifndef EXITCODE_H
#define EXITCODE_H

#include <stdbool.h>

/*
 * exitcode_wrap: the status the shell shows in $? when main returns
 * main_return.
 *
 * On Linux only the low 8 bits of the status reach the parent process, so
 * the result is main_return reduced modulo 256 into the range 0..255
 * (the mathematical modulo, which is never negative).
 *
 * Examples: 0 -> 0, 1 -> 1, 255 -> 255, 256 -> 0, 300 -> 44, -1 -> 255,
 *           -256 -> 0.
 *
 * Every int is valid input, including INT_MIN and INT_MAX. The function
 * must not overflow or otherwise trigger undefined behavior for any input.
 */
int exitcode_wrap(int main_return);

/*
 * exitcode_is_success: true if a program whose main returned main_return
 * counts as successful in the shell, that is, if the wrapped status is 0.
 *
 * Note: this is about what the shell sees. A main that returns 256 "succeeds".
 */
bool exitcode_is_success(int main_return);

/*
 * exitcode_name: a name for the wrapped status of main_return.
 *
 * Returns "EXIT_SUCCESS" if the wrapped status equals EXIT_SUCCESS,
 * "EXIT_FAILURE" if it equals EXIT_FAILURE, and "other" for anything else
 * (all three macros/values as in <stdlib.h>).
 *
 * The returned pointer refers to a string literal with static storage. The
 * caller must NOT free or modify it. Never returns NULL.
 */
const char *exitcode_name(int main_return);

#endif /* EXITCODE_H */
