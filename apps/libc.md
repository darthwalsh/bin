# Linux Distributions and C Standard Library (libc) Implementations

## glibc vs libgcc/libstdc++

Often conflated:
- **[glibc](https://www.gnu.org/software/libc/)** — the C standard library (`libc.so.6`). Provides `malloc`, `printf`, POSIX syscall wrappers, etc.
    - Full static linking is [officially discouraged](https://sourceware.org/glibc/wiki/FAQ#static_link); NSS/DNS plugins break.
- **[libgcc](https://gcc.gnu.org/onlinedocs/gccint/Libgcc.html)** — GCC's internal runtime helpers (e.g. soft-float ops, 64-bit arithmetic on 32-bit targets, stack unwinding).
- **[libstdc++](https://gcc.gnu.org/onlinedocs/libstdc++/)** — the C++ standard library (STL, exceptions, `std::string`, etc.).

The other libraries are linked dynamically by default (then you'd need `distroless/cc` [[docker.images|images]]). But they are safe to statically link.

## Distribution Summary

| OS                            | C Library                  | Notes                                                                                               |
| :---------------------------- | :------------------------- | :-------------------------------------------------------------------------------------------------- |
| Most Linux distros            | glibc                      | Default for mainstream distros (Debian, Ubuntu, RHEL, Fedora, Arch, openSUSE, etc.)                 |
| Alpine Linux                  | musl                       | Minimalist libc and userland                                                                        |
| Void Linux                    | glibc or musl              | Separate variants                                                                                   |
| NixOS                         | glibc (default)            | musl option is available                                                                            |
| ChromeOS                      | glibc                      | Base Linux environment uses a Gentoo-like glibc stack                                               |
| Android                       | Bionic libc                | Android-specific libc                                                                               |
| FreeBSD / OpenBSD / NetBSD    | BSD c                      | Each ships its own libc                                                                             |
| Embedded Linux                | glibc / musl / uClibc-ng   | Various embedded distributions                                                                      |
| Docker `FROM scratch`         | None                       | No userspace; static binary or manually bundled runtime/libs required                               |
| macOS (Darwin)                | libSystem                  | Apple's BSD-derived libc                                                                            |
| iOS                           | libSystem                  | Same Darwin userspace                                                                               |
| Windows (Win32 / native apps) | UCRT                       | Microsoft C runtime libraries; not a single Unix-style libc. On older versions, was called `MSVCRT` |
| Windows (Cygwin)              | newlib + Cygwin runtime    | POSIX layer on top of Windows                                                                       |
| Windows (MSYS2 / MinGW)       | msys2 runtime / UCRT       | Choice of building for MSYS2 POSIX layer or native MinGW target                                     |
| WASI                          | wasi-libc                  | C programs target the WASI syscall/ABI layer, not a host OS libc like glibc                         |
| WebAssembly (browser)         | toolchain-provided runtime | No libc from the browser; Emscripten typically provides a libc-like environment compiled in         |

More details about possible libc (or syscall) targets in [[os-syscall-interfaces]].
See [[docker.images]] for size of various docker images with glibc/musl/neither.
