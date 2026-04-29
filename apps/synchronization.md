#ai-slop #to-anki

Synchronization primitives for single-machine / shared-memory concurrency.

**Thread affinity** = "the same thread that acquired the lock must release it." Most ownership locks have this. Primitives that *don't* have it are noted explicitly.

Related: [[Concurrency]], [[Green Threads and Coroutines]]

---

## Q: Mutex (`pthread_mutex_t`)

### A:

* Main usage: exclusive ownership of a critical section by exactly one thread at a time. The canonical "tag-in / tag-out" primitive.
* Fundamental operations:
  * [`pthread_mutex_lock`](https://man7.org/linux/man-pages/man3/pthread_mutex_lock.3p.html) — block until acquired
  * `pthread_mutex_trylock` — non-blocking attempt
  * `pthread_mutex_unlock`
  * `pthread_mutex_init` / `pthread_mutex_destroy`
* Windows analogues: [`CRITICAL_SECTION`](https://learn.microsoft.com/en-us/windows/win32/sync/critical-section-objects) (in-process, fast), [`SRWLOCK`](https://learn.microsoft.com/en-us/windows/win32/sync/slim-reader-writer--srw--locks) exclusive mode, or a named [`Mutex` object](https://learn.microsoft.com/en-us/windows/win32/sync/mutex-objects) (cross-process)
* **Thread affinity: YES** — the thread that locks must unlock. Attempting to unlock from a different thread is undefined behavior (or an error with `PTHREAD_MUTEX_ERRORCHECK`).

---

## Q: Read-Write Lock (`pthread_rwlock_t`)

### A:

* Main usage: allow many concurrent readers *or* one exclusive writer — useful when reads dominate and writes are rare.
* Fundamental operations:
  * `pthread_rwlock_rdlock` / `pthread_rwlock_tryrdlock` — shared read lock
  * `pthread_rwlock_wrlock` / `pthread_rwlock_trywrlock` — exclusive write lock
  * `pthread_rwlock_unlock`
  * `pthread_rwlock_init` / `pthread_rwlock_destroy`
* Windows analogue: [`SRWLOCK`](https://learn.microsoft.com/en-us/windows/win32/sync/slim-reader-writer--srw--locks) — `AcquireSRWLockShared` / `AcquireSRWLockExclusive`
* **Thread affinity: YES** — the thread that acquires must release.
* Gotcha: writer starvation is possible if readers hold continuously; POSIX does not mandate fairness.

---

## Q: Binary Semaphore

### A:

* Main usage: a 0/1 gate for signaling or simple mutual exclusion.
* Fundamental operations:
  * wait / acquire (`sem_wait`)
  * post / release (`sem_post`)
* Unix: modeled with [`sem_t`](https://man7.org/linux/man-pages/man0/semaphore.h.0p.html) constrained to values 0 or 1
* Windows analogue: [Semaphore object](https://learn.microsoft.com/en-us/windows/win32/sync/semaphore-objects) with max count 1
* **Thread affinity: NO** — one thread can `sem_wait`, a *different* thread can `sem_post`. This is what makes it useful for signaling (producer/consumer wakeup), and what distinguishes it from a mutex.

---

## Q: Counting Semaphore (`sem_t`)

### A:

* Main usage: limit concurrent access to a resource pool of size N (e.g., connection pool, thread pool slots).
* Fundamental operations:
  * [`sem_init`](https://man7.org/linux/man-pages/man3/sem_init.3.html) with initial count / `sem_open` (named, cross-process)
  * `sem_wait` — decrement; block at 0
  * `sem_trywait` — non-blocking
  * `sem_timedwait`
  * `sem_post` — increment
  * `sem_destroy` / `sem_close`
* Windows analogue: [`CreateSemaphore`](https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-createsemaphorea) / `ReleaseSemaphore`
* **Thread affinity: NO** — any thread can post, any thread can wait. Not an ownership primitive.

---

## Q: Condition Variable (`pthread_cond_t`)

### A:

* Main usage: sleep until a predicate on shared state becomes true. Always paired with a mutex — the condvar signals; the mutex protects the state being tested.
* Fundamental operations:
  * [`pthread_cond_wait`](https://man7.org/linux/man-pages/man3/pthread_cond_wait.3p.html) — atomically releases mutex and sleeps
  * `pthread_cond_timedwait` — with timeout
  * `pthread_cond_signal` — wake one waiter
  * `pthread_cond_broadcast` — wake all waiters
  * `pthread_cond_init` / `pthread_cond_destroy`
* Windows analogue: [`CONDITION_VARIABLE`](https://learn.microsoft.com/en-us/windows/win32/sync/condition-variables) with `SleepConditionVariableCS` / `WakeConditionVariable`
* **Thread affinity: NO for the condvar itself** — any thread can signal. The *associated mutex* carries affinity.
* Gotcha: always re-check the predicate in a `while` loop after waking — spurious wakeups are permitted by POSIX.

---

## Q: Spinlock (`pthread_spinlock_t`)

### A:

* Main usage: very short critical sections where the expected wait time is less than the cost of a context switch. The waiting thread busy-loops (burns CPU) rather than sleeping.
* Fundamental operations:
  * `pthread_spin_lock` / `pthread_spin_trylock`
  * `pthread_spin_unlock`
  * `pthread_spin_init` / `pthread_spin_destroy`
* Windows analogue: kernel-mode `KeAcquireSpinLock` / user-mode spin patterns via `InterlockedExchange`
* **Thread affinity: YES** — acquiring thread must release.
* Gotcha: never hold a spinlock across any I/O, sleep, or long computation — other threads waste CPU the entire time. Appropriate mainly in kernel/driver code or real-time hot paths.

---

## Q: Atomic Compare-and-Swap (CAS)

### A:

* Main usage: atomically replace a value *only if it still equals an expected old value*. The fundamental building block for all lock-free data structures and distributed conditional writes.
* Fundamental operations:
  * load expected value
  * if equal, swap in new value atomically
  * return success/failure; retry loop on failure
* C/C++: [`atomic_compare_exchange_strong` / `_weak`](https://en.cppreference.com/w/c/atomic/atomic_compare_exchange); GCC builtin `__sync_bool_compare_and_swap`
* Windows analogue: [`InterlockedCompareExchange`](https://learn.microsoft.com/en-us/windows/win32/api/winnt/nf-winnt-interlockedcompareexchange)
* **Thread affinity: N/A** — not a lock; no ownership concept.
* Gotcha: [ABA problem](https://en.wikipedia.org/wiki/ABA_problem) — value changes A→B→A between load and swap; CAS succeeds incorrectly. Fix with a version/stamp counter.

---

## Q: Atomic Exchange / Swap

### A:

* Main usage: atomically write a new value and return the old value. Simpler than CAS; used for pointer handoff, flag setting, and simple spinlock words.
* Fundamental operations:
  * `atomic_exchange` — store new, return old
* C/C++: [`atomic_exchange`](https://en.cppreference.com/w/c/atomic/atomic_exchange)
* Windows analogue: [`InterlockedExchange`](https://learn.microsoft.com/en-us/windows/win32/api/winnt/nf-winnt-interlockedexchange)
* **Thread affinity: N/A** — not a lock.

---

## Q: Atomic Test-and-Set (`atomic_flag`)

### A:

* Main usage: atomically set a flag and learn whether it was previously clear. Simplest spinlock building block.
* Fundamental operations:
  * [`atomic_flag_test_and_set`](https://en.cppreference.com/w/c/atomic/atomic_flag_test_and_set) — set, returns old value
  * `atomic_flag_clear` — clear
* Windows analogue: bitwise interlocked operations
* **Thread affinity: N/A** — not a lock; caller is responsible for the unlock (clear).
* Note: `atomic_flag` is the only C11 atomic type guaranteed to be lock-free on all platforms.

---

## Q: Fetch-and-Add

### A:

* Main usage: atomically increment/decrement counters, allocate sequence numbers (ticket locks), manage reference counts.
* Fundamental operations:
  * [`atomic_fetch_add`](https://en.cppreference.com/w/c/atomic/atomic_fetch_add) — returns old value, adds delta
  * `atomic_fetch_sub`
* Windows analogue: [`InterlockedIncrement`](https://learn.microsoft.com/en-us/windows/win32/api/winnt/nf-winnt-interlockedincrement) / `InterlockedAdd`
* **Thread affinity: N/A** — not a lock.

---

## Q: Futex (Linux)

### A:

* Main usage: Linux's "fast user-space mutex" substrate. Spin/check in user space with an atomic; only enter the kernel (`FUTEX_WAIT` / `FUTEX_WAKE`) on actual contention. This is how `pthreads` mutexes and condvars are implemented under the hood.
* Fundamental operations:
  * atomic user-space check/change
  * [`FUTEX_WAIT`](https://man7.org/linux/man-pages/man2/futex.2.html) — sleep if value still matches
  * `FUTEX_WAKE` — wake N waiters
* Windows rough analogue: [`WaitOnAddress`](https://learn.microsoft.com/en-us/windows/win32/api/synchapi/nf-synchapi-waitonaddress) / `WakeByAddressSingle`
* **Thread affinity: N/A** — futex is infrastructure, not a user-visible lock.
* Not used directly in application code; shows up in profilers (`futex` syscall in stack traces = lock contention).

---

## Q: File Lock (`flock` / `fcntl`)

### A:

* Main usage: coordinate access to files *across processes* (not threads). Advisory by default — callers must cooperate.
* Fundamental operations:
  * [`flock(fd, LOCK_SH)`](https://man7.org/linux/man-pages/man2/flock.2.html) — shared (read) lock
  * `flock(fd, LOCK_EX)` — exclusive lock
  * `flock(fd, LOCK_UN)` — unlock
  * `fcntl(fd, F_SETLK, ...)` — record (byte-range) locks
* Windows analogue: [`LockFile`](https://learn.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-lockfile) / `LockFileEx`
* **Thread affinity: NO for `flock`** — `flock` locks are per open-file-description, not per thread. A fork or dup shares the lock. `fcntl` record locks are per-process.
* Gotcha: `flock` has no effect across NFS on many configurations.

---

## Q: Barrier (`pthread_barrier_t`)

### A:

* Main usage: make a fixed group of N threads all wait until every member has reached the same phase point before any proceeds. Used in phased parallel algorithms (e.g., parallel matrix operations).
* Fundamental operations:
  * [`pthread_barrier_wait`](https://man7.org/linux/man-pages/man3/pthread_barrier_wait.3p.html) — blocks until all N threads arrive; one thread gets `PTHREAD_BARRIER_SERIAL_THREAD`
  * `pthread_barrier_init` / `pthread_barrier_destroy`
* Windows analogue: [`InitializeSynchronizationBarrier`](https://learn.microsoft.com/en-us/windows/win32/api/synchapi/nf-synchapi-initializesynchronizationbarrier) / `EnterSynchronizationBarrier`
* **Thread affinity: N/A** — not a lock; any thread can call wait.

---

## Q: Once-Init (`pthread_once`)

### A:

* Main usage: guarantee an initialization function runs exactly once even under races — the lazy singleton pattern.
* Fundamental operations:
  * [`pthread_once`](https://man7.org/linux/man-pages/man3/pthread_once.3p.html)`(&once_control, init_fn)`
* C++11 equivalent: `std::call_once` with `std::once_flag`
* Windows analogue: [`InitOnceExecuteOnce`](https://learn.microsoft.com/en-us/windows/win32/api/synchapi/nf-synchapi-initonceexecuteonce)
* **Thread affinity: N/A** — calling thread is just a trigger; no ownership.

---

## Q: Memory Fence / Memory Barrier

### A:

* Main usage: constrain CPU and compiler reordering of memory operations — ensures a store is visible before a subsequent load, or that all prior stores complete before a critical operation. Not a lock; controls *visibility*, not *exclusivity*.
* Fundamental operations:
  * [`atomic_thread_fence(memory_order_acquire)`](https://en.cppreference.com/w/c/atomic/atomic_thread_fence) — no load reordered before this point
  * `atomic_thread_fence(memory_order_release)` — no store reordered after this point
  * `atomic_thread_fence(memory_order_seq_cst)` — full fence
* Windows analogue: [`MemoryBarrier()`](https://learn.microsoft.com/en-us/windows/win32/api/winnt/nf-winnt-memorybarrier), acquire/release on interlocked operations
* **Thread affinity: N/A** — affects ordering, not ownership.
* Most lock/unlock implementations include the appropriate fences implicitly; you only need explicit fences in lock-free code.

---

## Q: Monitor

### A:

* Main usage: a higher-level object-oriented abstraction that bundles shared state + a mutex + one or more condition variables into one unit. Invented by Hoare (1974). Java's `synchronized` methods are monitors.
* Fundamental operations:
  * enter monitor (acquire internal lock)
  * exit monitor (release lock)
  * `wait` — release lock and sleep on condition
  * `notify` / `notify_all` — wake waiters
* Unix: no single POSIX type — implemented from `pthread_mutex_t` + `pthread_cond_t`
* Windows: [`CRITICAL_SECTION`](https://learn.microsoft.com/en-us/windows/win32/sync/critical-section-objects) + `CONDITION_VARIABLE` together; or .NET's `Monitor` class / `lock` keyword
* **Thread affinity: YES** — internal mutex carries affinity.

---

## Q: Event / Manual-Reset and Auto-Reset Event

### A:

* Main usage: signal state changes. An auto-reset event wakes exactly one waiter then resets; a manual-reset event stays signaled until explicitly reset (wakes all waiters).
* Fundamental operations:
  * set (signal)
  * reset (clear)
  * wait
* Unix: no direct POSIX equivalent — modeled with `pthread_cond_t` + `pthread_mutex_t`, `sem_t`, or `eventfd`
* Windows: [`CreateEvent`](https://learn.microsoft.com/en-us/windows/win32/api/synchapi/nf-synchapi-createeventa) / `SetEvent` / `ResetEvent` / `WaitForSingleObject`
* **Thread affinity: NO** — any thread can set or reset.

---

## Q: `eventfd` (Linux)

### A:

* Main usage: a Linux file-descriptor-based counter that works with `poll`/`epoll`/`select`. Bridge between the event-loop world and thread signaling.
* Fundamental operations:
  * [`eventfd()`](https://man7.org/linux/man-pages/man2/eventfd.2.html) — create with initial count
  * `write(fd, &val, 8)` — add to counter (signal)
  * `read(fd, &val, 8)` — consume counter (blocks at 0); in semaphore mode decrements by 1
* **Thread affinity: NO** — any thread (or process) holding the fd can read/write.
* Useful for waking an `epoll` reactor from another thread without a pipe.

---

## Q: Lock Instrumentation / Contention Profiling

### A:

* Main usage: not a separate primitive — the practice of measuring lock behavior: contention rate, hold time, wait time, owner identity. Essential for diagnosing performance bottlenecks.
* Tooling:
  * Linux: [`perf lock`](https://man7.org/linux/man-pages/man1/perf-lock.1.html), `eBPF` / `bpftrace`, `ThreadSanitizer` (`-fsanitize=thread`)
  * macOS: Instruments → Thread States
  * Windows: [ETW](https://learn.microsoft.com/en-us/windows/win32/etw/event-tracing-portal), Visual Studio Concurrency Visualizer
  * Language-level: Java `-XX:+PrintContended`, Go `GODEBUG=mutex...`
* **Thread affinity: N/A** — observability layer.

---

## Quick mental grouping

* **Ownership locks** (affinity YES): mutex, rwlock, spinlock, monitor
* **Signaling tools** (affinity NO): condvar, binary semaphore, event, eventfd
* **Resource pools**: counting semaphore
* **Atomic building blocks** (N/A): CAS, exchange, test-and-set, fetch-add
* **Phase / control tools** (N/A): barrier, once-init
* **Visibility tools** (N/A): memory fence
* **Infrastructure** (N/A): futex (substrate under pthreads)
* **Cross-process**: file lock, named semaphore, named mutex
