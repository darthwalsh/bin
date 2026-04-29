Every process eventually needs [[kernel-mode]], going through the OS's published interface. But there are often multiple interfaces your runtime can target.

The overwhelming choice is to go through the OS-provided [[libc]]. On top of C-bindings for syscalls, libc often provides runtime features: DNS resolution, locale/timezone handling, threading, C runtime startup (`_start`), errno mapping, etc.

I'm also interested in how Go/Rust implements this on each platform.
## Linux

### Recommended: libc (glibc or musl)
The conventional target is a C library that wraps the raw syscall ABI:
- **[glibc](https://www.gnu.org/software/libc/)** shipped with Debian, Ubuntu, Fedora, RHEL, and most desktop/server distros
- **[musl](https://musl.libc.org/)** — the default on [Alpine Linux](https://wiki.alpinelinux.org/wiki/Musl)

Gotcha: a binary compiled against glibc links the glibc `.so` at a minimum version, meaning you should compile your app on that old system. If you need to support both glibc and musl, you must either ship two binaries or use raw syscalls / static linking (see below).

- Rust `x86_64-unknown-linux-musl` target statically links musl, so the binary is self-contained but still goes through a real libc
	- I incorrectly thought that this was the default target for all Linux systems! However, on glibc systems rust defaults to dynamically linked `x86_64-unknown-linux-gnu`

### Alternative: raw syscalls
The Linux kernel guarantees stability of the **syscall ABI** (number, argument layout, return convention for each architecture). A binary that issues `syscall` instructions directly with hardcoded numbers will continue to work across kernel versions.

This is what **Go does for fully static binaries** avoiding any libc to produce a single binary that runs on any Linux:
- Go issues syscalls directly (via assembly stubs in the `syscall` package), carrying its own resolver and scheduler — no libc involved.

Trade-off: Go runtime now owns the userland contract — DNS resolution, thread-local storage init, locale, signal semantics. Go ships its own resolver and runtime scheduler.

## macOS

### Recommended: libSystem (POSIX-ish)
Apple's supported contract is **[libSystem](https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man3/intro.3.html)**, the default libc:
- Go on Darwin routes through libSystem trampolines (function-pointer stubs) rather than hardcoding syscall numbers
- Rust's `std` on macOS links libSystem via the `libc` crate

### Raw syscalls are a dead end on macOS
Go [switched away from syscalls](https://go.dev/src/syscall/syscall_darwin.go) on macOS. Apple [deprecated `syscall(2)`](https://developer.apple.com/forums/thread/108030) as "unsupported" starting in macOS 10.12 (Sierra, 2016). The enforcement mechanism is **version instability**: XNU syscall numbers are a private implementation detail, changing between macOS versions.
## Windows

### Recommended: Windows API (AKA Win32)
The stable, documented compatibility contract for user-mode applications is the **Windows API** (historically called **Win32**): documented functions exposed through libraries such as `kernel32.dll` or `user32.dll`. Microsoft maintains strong backward compatibility for this API since Windows NT 3.1. On 64-bit Windows, **WOW64** allows 32-bit x86 applications to run seamlessly, with `SysWOW64` providing the 32-bit system binaries used for that compatibility layer.

- Go uses [`syscall.NewLazyDLL("kernel32.dll").NewProc(...)`](https://go.dev/wiki/WindowsDLLs) to call Win32 functions.
- Rust uses the [`windows` / `windows-sys` crates](https://learn.microsoft.com/en-us/windows/dev-environment/rust/rust-for-windows) (windows-rs), which generate typed Rust bindings directly to Win32 and WinRT surfaces. 

### ntdll.dll is unstable
Many Win32 functions bottom out in `ntdll.dll`, which contains user-mode stubs for NT kernel calls (`NtCreateFile`, `NtReadFile`, etc.). ntdll is the true last stop before the `syscall` instruction. Its functions are sometimes named `Nt*` or `Zw*` (the `Zw*` prefix historically marks kernel-mode callers, but user-mode code uses both names in practice).

Calling ntdll directly is possible and sometimes useful (certain primitives are only exposed here), but it is **not a stable public contract** — Microsoft documents Win32 as the supported surface, not the NT layer.

### Raw syscalls are unstable
Windows NT syscall numbers are not documented and are **not stable across Windows versions** — they change in minor updates, not just major releases. This is confirmed by kernel researchers and is why no mainstream language runtime bakes them in. See [HN discussion](https://news.ycombinator.com/item?id=32921086) for real-world go history.

### WinRT or Windows App SDK Are Complimentary
[Windows Runtime (WinRT)](https://learn.microsoft.com/en-us/uwp/) is a language-neutral component model exposed as a C++ interface with projections into C#, JS, Rust, etc. It covers modern app surfaces (notifications, file pickers, camera, etc.) but **cannot** replace Win32 for core runtime primitives (processes, low-level I/O, sockets).

The [Windows App SDK](https://learn.microsoft.com/en-us/windows/windows-app-sdk/) is additive: it brings modern Windows features and WinUI to existing desktop frameworks including Win32/WPF/WinForms.

The practical model for a runtime is Win32 as the core substrate, with WinRT/Windows App SDK layered on for modern-app capabilities.

[UWP apps](https://learn.microsoft.com/en-us/uwp/win32-and-com/win32-and-com-for-uwp-apps) (the closest to a "WinRT-only" model) still have access to a documented subset of Win32/COM APIs, but AppContainer enforced a restricted API surface. In Windows 8 there was a hard split between sandboxed Store/WinRT apps vs. classic desktop; Windows 11 bridges this.

### Win16 no Longer Supported on 64-Bit Windows
16-bit Windows (Win16) APIs ran on [NTVDM](https://learn.microsoft.com/en-us/windows/compatibility/ntvdm-and-16-bit-app-support). NTVDM is absent from all 64-bit Windows editions — Win16 binaries cannot run on any current Windows without emulation/VM. Not a viable target. Backwards Compatibility should only go so far!
