#ai-slop
# Linux Write Cheatsheet

The three-level stack:

- **Layer 3 — Language runtimes**: Rust `Write` trait, Go `io.Writer`, C++ `ostream`
- **Layer 2 — stdio / libc**: `fwrite`, `fprintf`, `fputc` — user-space buffers, eventually calls Layer 1
- **Layer 1 — Raw syscalls**: `write`, `pwrite`, `writev` — bytes go to the kernel now

---

## Layer 1: Raw Syscalls

| Call | Description |
|------|-------------|
| `write(fd, buf, n)` | Write up to *n* bytes. Returns bytes written (may be partial). |
| `pwrite(fd, buf, n, offset)` | Like `write` but at explicit offset; does **not** change the fd's seek position. Good for concurrent writers. |
| `writev(fd, iov[], iovcnt)` | Scatter-gather: write multiple non-contiguous buffers in one syscall, in order. Reduces syscall count. |
| `pwritev(fd, iov[], iovcnt, offset)` | `writev` + explicit offset. |
| `sendfile(out_fd, in_fd, offset, count)` | Zero-copy: kernel moves data between two fds without user-space touching the bytes. |
| `splice(fd_in, fd_out, len, flags)` | Move data between a pipe and another fd; or between two pipes. No user buffer. |
| `tee(fd_in, fd_out, len, flags)` | Copy data between two pipes without consuming from the source. |
| `send(sockfd, buf, len, flags)` | Socket-specific write with flags (e.g. `MSG_NOSIGNAL`, `MSG_MORE`). |
| `sendmsg(sockfd, msghdr, flags)` | Socket write with scatter-gather + ancillary data (fd passing, credentials). |

**Assumptions you must handle yourself:**
- Partial writes: `write` can return less than *n* — you need a retry loop.
- Blocking vs. non-blocking: determined by fd flags (`O_NONBLOCK`). Non-blocking returns `EAGAIN` instead of blocking.
- Thread safety: the kernel protects individual syscall atomicity, but no higher-level ordering guarantee across calls.

## Layer 2: stdio Buffering (`fwrite` family)

| Call | Notes |
|------|-------|
| `fwrite(ptr, size, n, FILE*)` | Buffered write. Copies into user-space buffer; syscall happens when buffer fills or you flush. |
| `fputs(str, FILE*)` | Buffered string write (no format parsing). |
| `fputc(c, FILE*)` | Buffered single character. |
| `fprintf(FILE*, fmt, ...)` | Format then buffer. |
| `fflush(FILE*)` | Force drain buffer → `write(2)` now. |
| `fwrite_unlocked` / `fputc_unlocked` | Same as above but **no internal lock**. Faster; you manage concurrency. |
| `putchar_unlocked(c)` | Fastest single-char write to stdout; no lock. |

### How buffering works

`FILE*` owns a user-space buffer (typically 4–8 KB). `fwrite` copies your data into that buffer. The actual `write(2)` syscall only happens when:
1. The buffer fills up.
2. For line-buffered streams: a `\n` is written.
3. You call `fflush()`.
4. The stream is closed.

**Buffer modes** (controlled by `setvbuf` / `setbuf`):

| Mode           | Constant | Behavior                                                            |
| -------------- | -------- | ------------------------------------------------------------------- |
| Fully buffered | `_IOFBF` | Flush only when buffer full or `fflush`. Default for regular files. |
| Line buffered  | `_IOLBF` | Flush on `\n`. Default for stdout **when connected to a terminal**. |
| Unbuffered     | `_IONBF` | Every write goes straight to the kernel. Default for stderr.        |

**The stdout ordering trap**: If you mix `printf` (buffered, line-buffered to terminal) with raw `write(1, ...)` (unbuffered), output can appear out of order because the `printf` data is still sitting in the stdio buffer. Fix: flush stdlo.

The same trap bites when you `fork()`: both parent and child share a copy of the unflushed buffer. Both may flush it, duplicating output. Always `fflush` before `fork`.

## Layer 3: Language Runtimes
**Rust** has **no libc dependency** for its standard `Write` trait — it calls the OS syscall directly via `syscall!` in `std::sys`. **No glibc, no stdio buffer** unless you add one explicitly.

**Go** has its own runtime and **does not use glibc** (uses its own syscall layer, even on Linux). `os.File.Write` calls `write(2)` directly. Buffering is opt-in via `bufio`.

**C++** streams: `std::ostream` (e.g. `std::cout`) goes through stdio by default (`sync_with_stdio`), so it is safe to mix `cout` and `printf` (but decoupling would be faster).
 dis
## Synchronization / Locking
The kernel won't corrupt your data, but it won't order your writes across threads either. stdio will keep its buffer uncorrupted, but you still get interleaved output if two goroutines/threads share a `FILE*`. Unlocked variants give maximum throughput at the cost of all guarantees.

In **kernel**, `write(2)` is atomic for pipes ≤ `PIPE_BUF` (~4KB); larger writes may interleave across threads. For files, no cross-thread write ordering guarantee from the kernel alone.

In **stdio**, `fwrite`, `fprintf`, `fputc` all acquire a **per-`FILE*` mutex** internally (POSIX requires this). Concurrent writers to the same `FILE*` won't corrupt the buffer, but they may interleave. 
> [!WARNING] the `_unlocked` variants require syncronization!

**Rust** and **Go** have their own runtime-level synchronization mechanisms.

---

## Extras

### `io_uring` — Async syscall batching

`io_uring` (Linux 5.1+) lets you submit batches of I/O operations to a shared ring buffer between user space and the kernel — no syscall per operation when the kernel can drain the ring without you.

- **Submission queue (SQ)**: you write operation descriptors here.
- **Completion queue (CQ)**: kernel writes results here.
- **Zero-copy mode** (`IORING_OP_WRITE_FIXED`): register buffers once; avoid per-call copies.
- **Fully async**: submit a batch, do other work, poll completions. No blocking.

Pairs well with `writev` semantics but amortizes syscall overhead further. Used in high-performance [[web.servers]] (nginx, Rust Tokio's `io-uring` feature, `liburing` in C).

### Zero-copy: `sendfile`, `splice`, `tee`

When copying file-to-socket or pipe-to-pipe, normal flow is: kernel reads into page cache → user copies to buffer → kernel writes from buffer. These calls skip user space entirely:

- `sendfile`: file fd → socket fd. The classic HTTP static file server trick.
- `splice`: pipe ↔ any fd. Compose with `tee` to fan out.
- `tee`: duplicate pipe data without consuming — good for logging a stream while forwarding it.

### Reducing allocations when moving data

Unnecessary allocations are the hidden tax on I/O pipelines. Libraries that help:

| Strategy                           | Libraries / Mechanisms                                                                                                                                                                                                                                             |
| ---------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Scatter-gather (`iovec`)**       | `writev` / `pwritev` — write from multiple non-contiguous buffers without copying them into one. Used by Rust's `Write::write_vectored`, Go's `(*net.TCPConn).WriteTo` internals.                                                                                  |
| **Ring buffers**                   | Avoid allocation entirely by reusing fixed memory. Used in `io_uring`, kernel pipe buffers, and userspace libs like `LMAX Disruptor`.                                                                                                                              |
| **Buffer pools / slab allocators** | Pre-allocate fixed-size chunks, hand them out and reclaim without `malloc`. `jemalloc`, `mimalloc`, Go's `sync.Pool`, Rust `bytes::BytesMut` pooling.                                                                                                              |
| **Memory-mapped I/O (`mmap`)**     | Map file into address space; writes via `memcpy` into the mapping avoid a syscall entirely until the OS decides to flush dirty pages (`msync` for explicit control). High throughput for large files, but no ordering guarantees across processes without `msync`. |
| **`MSG_MORE` / `TCP_CORK`**        | Tell the kernel to accumulate data before sending — User-space writes won't trigger **partial** TCP segments until you un-cork or a 200ms timeout occurs. Reduces small-packet overhead without needing `writev`.                                                  |
