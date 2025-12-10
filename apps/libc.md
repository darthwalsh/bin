#ai-slop
Linux Distributions and C Standard Library (libc) Implementations

## Distribution Summary

| OS                                   | C Library                 | Notes                                                                                 |
| :----------------------------------- | :------------------------ | :------------------------------------------------------------------------------------ |
| **Most other Linux distros**         | **glibc**                 | Default for mainstream distros (Debian, Ubuntu, RHEL, Fedora, Arch, openSUSE, etc.)  |
| **Alpine Linux**                     | **musl**                  | Lightweight, minimal (~5MB base image)                                                |
| **Void Linux**                       | **glibc** or **musl**     | User chooses which version to install                                                 |
| **NixOS**                            | **glibc** (primary)       | Supports musl via `pkgsMusl` (Tier 3 platform)                                        |
| **ChromeOS**                         | **glibc**                 | Base Linux environment uses a Gentoo-like glibc stack                                 |
| **Android**                          | **Bionic libc**           | Google's libc optimized for mobile devices                                            |
| **Docker `FROM scratch`**           | **None**                  | Requires statically linked binaries (no dynamic libc in the base image)              |
| **Windows (Win32 / native apps)**    | **MSVCRT / UCRT**         | Microsoft C runtime libraries; shipped with the OS and Visual C++ runtimes           |
| **Windows (Cygwin / MSYS2 layer)**   | **newlib / custom libc**  | POSIX compatibility layers on top of Windows; not used by native Win32 binaries      |
| **macOS (Darwin)**                   | **libSystem / Apple libc**| BSD-derived libc in `libSystem.dylib`, not glibc or musl                              |
| **FreeBSD / OpenBSD / NetBSD**       | **BSD libc**              | Each ships its own libc implementation, distinct from glibc and musl                 |

## Alternative for Embedded

- dietlibc
- Newlib
- uClibc-ng
- klibc (used in initramfs in early boot)

## Container Base Images

| Base Image | libc| Typical Size | Use Case |
| :--- | :--- | :--- | :--- |
| `FROM scratch` | None | 0 MB | Statically linked (Go, Rust, C/C++ with `-static`) |
| `FROM alpine` | musl | 5 MB | Minimal dynamic linking with musl |
| `FROM debian:slim` | glibc | 50 MB | Maximum compatibility |
