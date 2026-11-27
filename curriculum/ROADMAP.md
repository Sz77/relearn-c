# Roadmap: zero to advanced C

Small topics (about 1–2 h each), built in order. The **curriculum agent** creates the next
`⬜ todo` row when the previous topic is `✅ done`. It may insert a review topic (🔁) when
`progress/weak-spots.md` shows gaps. The **review agent** sets `✅ done`.

Status: `⬜ todo` · `🟡 in progress` (folder created, exercises open) · `✅ done` · `🔁` = inserted review topic

<!-- The table is parsed by agents: keep one row per topic and keep the columns. -->

| #  | Topic | Builds on | Folder | Status |
|----|-------|-----------|--------|--------|
| 1  | Hello world and the toolchain: preprocess → compile → assemble → link, gcc flags, warnings | — | | ⬜ todo |
| 2  | Multiple files: translation units, headers, declarations vs definitions, include guards, linking | 1 | | ⬜ todo |
| 3  | Variables and types: integer types, sizes, `sizeof`, `<limits.h>`, `<stdint.h>`, `<stdbool.h>` | 1 | | ⬜ todo |
| 4  | Operators and expressions: integer division, promotions, signed overflow UB, precedence | 3 | | ⬜ todo |
| 5  | Control flow: `if`, `switch`, loops, `break`/`continue` | 4 | | ⬜ todo |
| 6  | Functions: prototypes, pass by value, return values, recursion | 5 | | ⬜ todo |
| 7  | Formatted I/O: `printf`/`scanf` families, format specifiers, checking return values | 6 | | ⬜ todo |
| 8  | Debugging: reading compiler errors, gdb basics, reading ASan/UBSan reports | 7 | | ⬜ todo |
| 9  | Arrays: declaration, initialization, bounds, passing arrays to functions | 6 | | ⬜ todo |
| 10 | Pointers I: addresses, `&` and `*`, pointers as out-parameters, `NULL` | 9 | | ⬜ todo |
| 11 | Pointers II: pointer arithmetic, array decay, pointer comparison rules | 10 | | ⬜ todo |
| 12 | Strings: null termination, `<string.h>`, writing your own string functions | 11 | | ⬜ todo |
| 13 | Safe string handling: buffer overflows, `snprintf`, `strncpy` pitfalls, bounded APIs | 12 | | ⬜ todo |
| 14 | `const` and qualifiers: `const T *` vs `T *const`, const-correct APIs | 11 | | ⬜ todo |
| 15 | Multidimensional arrays and arrays of pointers | 11 | | ⬜ todo |
| 16 | Command-line arguments: `argc`/`argv`, exit codes, small CLI tools | 12 | | ⬜ todo |
| 17 | Scope, linkage and storage duration: `auto`/`static`/`extern`, stack vs static memory | 2, 6 | | ⬜ todo |
| 18 | Dynamic memory: `malloc`/`calloc`/`realloc`/`free`, checking allocation failure | 17 | | ⬜ todo |
| 19 | Memory errors and ownership: leaks, double free, use-after-free, ownership conventions | 18 | | ⬜ todo |
| 20 | Dynamic arrays: build a growable vector of ints | 19 | | ⬜ todo |
| 21 | Structs: definition, initialization, passing by pointer, designated initializers | 20 | | ⬜ todo |
| 22 | Enums and unions: tagged unions, exhaustive `switch` | 21 | | ⬜ todo |
| 23 | `typedef` and opaque types: encapsulation with incomplete types | 21 | | ⬜ todo |
| 24 | Bit manipulation: bitwise operators, masks, flags, shifts and their UB | 4 | | ⬜ todo |
| 25 | The preprocessor: macros, pitfalls, conditional compilation, `#` and `##` | 2 | | ⬜ todo |
| 26 | Error handling patterns: return codes, `errno`, `goto cleanup`, consistent APIs | 19 | | ⬜ todo |
| 27 | Text file I/O: `fopen`, `fgets`, `fprintf`, error checking, `fclose` | 26 | | ⬜ todo |
| 28 | Binary file I/O: `fread`/`fwrite`, `fseek`, endianness and portability | 27 | | ⬜ todo |
| 29 | Robust input parsing: `strtol`/`strtod`, line reading, validating untrusted input | 27 | | ⬜ todo |
| 30 | Linked lists: singly and doubly linked, ownership, iteration patterns | 21 | | ⬜ todo |
| 31 | Stacks and queues: array- and list-based, ring buffers | 30 | | ⬜ todo |
| 32 | Hash tables: hashing, chaining vs open addressing, resizing | 30 | | ⬜ todo |
| 33 | Binary search trees: insert, search, delete, traversal, freeing recursively | 30 | | ⬜ todo |
| 34 | Sorting and searching: implement sorts, `qsort`, `bsearch`, complexity | 9 | | ⬜ todo |
| 35 | Function pointers and callbacks: syntax, dispatch tables, comparators | 34 | | ⬜ todo |
| 36 | Generic programming with `void *`: element size, generic containers | 35 | | ⬜ todo |
| 37 | Variadic functions: `<stdarg.h>`, writing a mini `printf` | 35 | | ⬜ todo |
| 38 | Undefined behavior deep dive: strict aliasing, sequence points, optimizer surprises | 24 | | ⬜ todo |
| 39 | Memory layout: alignment, padding, `offsetof`, struct packing | 21 | | ⬜ todo |
| 40 | Modern C: `_Static_assert`, `_Generic`, `restrict`, `inline`, compound literals | 38 | | ⬜ todo |
| 41 | Custom allocators: arena and pool allocators | 39 | | ⬜ todo |
| 42 | Building libraries: static and shared libraries, symbol visibility, Makefiles | 2, 23 | | ⬜ todo |
| 43 | Processes: `fork`, `exec`, `wait`, exit status | 26 | | ⬜ todo |
| 44 | File descriptors and syscalls: `open`/`read`/`write`, `errno`, partial reads/writes | 43 | | ⬜ todo |
| 45 | Signals: handlers, async-signal-safety, `sigaction` | 44 | | ⬜ todo |
| 46 | Pipes and IPC: `pipe`, `dup2`, building a mini shell pipeline | 44 | | ⬜ todo |
| 47 | Threads: `pthread_create`/`join`, data races, ThreadSanitizer | 43 | | ⬜ todo |
| 48 | Synchronization: mutexes, condition variables, producer/consumer queue | 47, 31 | | ⬜ todo |
| 49 | Atomics and C11 threads: `<stdatomic.h>`, memory orders (intro), `<threads.h>` | 48 | | ⬜ todo |
| 50 | Sockets: TCP client and server, handling partial I/O | 44 | | ⬜ todo |
| 51 | Event loops: `poll`, non-blocking I/O, a multi-client server | 50 | | ⬜ todo |
| 52 | Capstone: a small key-value store server (hash table + sockets + persistence) | 32, 28, 51 | | ⬜ todo |
