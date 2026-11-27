# Roadmap: zero to advanced C → Linux kernel and drivers

End goal: **Linux kernel and device-driver development.** Parts 1–8 build solid user-space C;
Part 9 bridges to kernel idioms; Parts 10–11 are kernel modules and real drivers (run in a VM).

Small topics (about 1–2 h each), built in order. The **curriculum agent** creates the next
`⬜ todo` row when the previous topic is `✅ done`. It may insert a review topic (🔁) when
`progress/weak-spots.md` shows gaps. The **review agent** sets `✅ done`.

Status: `⬜ todo` · `🟡 in progress` (folder created, exercises open) · `✅ done` · `🔁` = inserted review topic

<!-- The table is parsed by agents: keep one row per topic and keep the columns. -->

| #  | Topic | Builds on | Folder | Status |
|----|-------|-----------|--------|--------|
| 1  | Hello world and the toolchain: preprocess → compile → assemble → link, gcc flags, warnings | — | 01-toolchain | 🟡 in progress |
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
| 53 | Intrusive data structures: `container_of`, `offsetof`, a `list_head`-style doubly linked list | 30, 39 | | ⬜ todo |
| 54 | GNU C and kernel idioms: `typeof`, statement expressions, `__attribute__`, `likely`, `ERR_PTR`, negative errno returns | 40, 26 | | ⬜ todo |
| 55 | Kernel coding style: `checkpatch.pl`, the kernel style guide, rewriting earlier code in kernel style | 54 | | ⬜ todo |
| 56 | Virtual memory from user space: pages, `mmap`, page faults, `/proc/self/maps`, caches | 44 | | ⬜ todo |
| 57 | Low-level concurrency: memory barriers, spinlocks vs mutexes, lock-free basics, the idea of RCU | 49 | | ⬜ todo |
| 58 | Inline assembly and the ABI: calling conventions, `asm volatile`, reading compiler output | 39 | | ⬜ todo |
| 59 | Kernel dev setup: build a kernel, boot it in QEMU with virtme-ng, `dmesg`, reading an oops | 55 | | ⬜ todo |
| 60 | First kernel module: `module_init`/`module_exit`, `printk`, module parameters, Kbuild out-of-tree | 59 | | ⬜ todo |
| 61 | Kernel memory: `kmalloc`/`kfree`, `vmalloc`, GFP flags, slab caches, `goto` error unwinding | 60 | | ⬜ todo |
| 62 | Kernel data structures: `list_head`, `hlist`, rbtree, xarray | 61, 53 | | ⬜ todo |
| 63 | Character device driver: `cdev`, `file_operations`, `copy_to_user`/`copy_from_user` | 61 | | ⬜ todo |
| 64 | User interfaces: `ioctl` design, sysfs attributes, debugfs, procfs | 63 | | ⬜ todo |
| 65 | Kernel concurrency: spinlocks, mutexes, atomics, wait queues, completions, lockdep | 63, 57 | | ⬜ todo |
| 66 | Deferred work and time: timers, hrtimers, workqueues, kthreads, softirq/tasklet concepts | 65 | | ⬜ todo |
| 67 | Blocking I/O and `poll`: sleeping readers, `poll`/`select` support in a driver | 66 | | ⬜ todo |
| 68 | Memory mapping in drivers: implementing `mmap`, `remap_pfn_range`, page refcounts | 63, 56 | | ⬜ todo |
| 69 | Kernel debugging: KASAN, UBSAN, kmemleak, lockdep, ftrace, kgdb in QEMU | 65 | | ⬜ todo |
| 70 | Kernel testing: KUnit and kselftest | 62 | | ⬜ todo |
| 71 | The device model: buses, devices, drivers, `probe`/`remove`, `devm_*` managed resources | 64 | | ⬜ todo |
| 72 | Platform drivers and device tree (QEMU `virt` machine) | 71 | | ⬜ todo |
| 73 | PCI drivers I: QEMU `edu` device, BARs, MMIO, `ioremap`, `readl`/`writel` | 71 | | ⬜ todo |
| 74 | Interrupts: `request_irq`, threaded IRQs, top/bottom halves, MSI (edu device) | 73, 66 | | ⬜ todo |
| 75 | DMA: coherent and streaming mappings, DMA with the edu device | 74 | | ⬜ todo |
| 76 | Upstream workflow: `git format-patch`, commit messages, `get_maintainer.pl`, review etiquette | 55 | | ⬜ todo |
| 77 | Kernel capstone: full PCI driver for the edu device (char interface, IRQ, DMA, sysfs, KUnit tests) | 75, 70, 64 | | ⬜ todo |
