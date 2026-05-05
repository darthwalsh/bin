#ai-slop
[CRIU (Checkpoint/Restore In Userspace)](https://criu.org/Main_Page) freezes a running Linux process tree, serializes its state to disk, and later restores it as if nothing happened. It runs in userspace and talks to the kernel via `/proc`, `ptrace`, `netlink`, and misc kernel APIs — not a VM snapshot, more like "rebuild the process using Linux primitives."

See [[docker-checkpoint]] for how to use CRIU with containers. See [[snapshots]] for how this compares to filesystem snapshots and debugger record/replay.

## What CRIU saves: the mental model

A Linux process is:

- **Memory**: anonymous pages, file-backed mappings, shared memory
- **CPU state**: registers, instruction pointer, signal state
- **Kernel objects held by the process**: file descriptors (files, pipes, sockets, eventfd, epoll, signalfd...), namespaces (mount/net/pid/user/uts/ipc), cgroups, capabilities, seccomp filters, timers, futexes, threads, creds/ids, rlimits, cwd/root

CRIU serializes enough of that state to recreate it later on the same (or a very similar) Linux host.

### Images: what's in the checkpoint directory

A checkpoint becomes a directory of image files:

- **process metadata**: pids, parent/child links, creds, rlimits, namespaces
- **memory maps**: VMA layout + page contents (anonymous pages, some file-backed deltas)
- **fd table**: each FD type has its own representation
- **IPC state**: pipes, UNIX sockets, shm, semaphores, message queues
- **thread state**: stacks, TLS, registers, futex queues (where possible)
- **network state**: sockets, TCP connection state, routing/addr state (namespace-level)

### Freezing: ptrace, parasite code, pre-dump

To get a consistent snapshot, CRIU stops execution at a known point:

- **ptrace-seize + parasite**: CRIU attaches to all tasks and injects a tiny helper ("parasite") that runs *inside the target process context* to read/write certain state efficiently (especially memory-related things). All threads are coordinated so CRIU doesn't snapshot half-updated data structures.
- **Pre-dump (incremental)**: CRIU can copy most memory pages while the process keeps running, then do a short stop-the-world final dump. Used for live migration to minimize downtime.
- **Lazy pages**: restore can start before all pages are copied; missing pages are fetched on-demand via a **page server** at the source.

## Restore ordering

Restore must reconstruct dependencies in order:

1. Create namespaces / cgroups context
2. Recreate process tree "skeleton"
3. Recreate shared resources (shared memory, IPC)
4. Recreate FDs (pipes, sockets)
5. Map memory regions at the *same virtual addresses* (often load-address–sensitive)
6. Restore thread registers / signals
7. Resume

If anything can't be recreated identically (e.g., an external TCP peer changed), restore fails.

## Namespaces: why containers are the sweet spot

CRIU is commonly used with containers because [[LinuxNamespaces]] give you a "sealed world":

- **MNT namespace**: filesystem layout must match (same paths/devices)
- **NET namespace**: CRIU can restore interfaces/addresses inside that netns
- **PID namespace**: PID values matter to processes; restoring PID namespaces is central for container migration

Container runtimes orchestrate environment matching; CRIU focuses on the process state.

## What breaks (limitations)

CRIU works best when the world is controlled:

- **TCP connections to external hosts**: "TCP repair" exists but cross-host migration of arbitrary TCP is fragile — the peer must still be in a compatible state.
- **File-backed mappings and filesystem identity**: restore assumes the same file content/inode semantics are available at the same paths.
- **Devices and special FDs**: GPUs, some `/dev` nodes, and proprietary drivers don't support checkpoint well.
- **Kernel version / config mismatches**: dump on one kernel, restore on another can fail if internal kernel object formats differ. Often requires the same minor version.
- **Security features**: seccomp filters, LSM policies (SELinux/AppArmor), capabilities, user namespaces — restoring may be blocked without careful configuration (often requires disabling seccomp: `--security-opt=seccomp:unconfined`).
- **Shared memory / huge pages / special VMAs**: mostly supported, but corner cases exist with certain hugetlb/shmem configurations.

## Glossary

- **dump / restore**: the two phases (checkpoint = dump, then restore later)
- **images**: serialized checkpoint data directory
- **pre-dump**: incremental memory copying while the process is still running
- **lazy pages**: restore starts before all pages are transferred; missing pages fetched on-demand
- **page server**: process that serves memory pages during lazy/live migration
- **parasite**: a tiny code stub injected into the target process to help CRIU read/write its state

## "What CRIU needs to succeed" checklist

- Same CPU architecture
- Very similar kernel (often same minor version)
- Matching filesystem (paths + contents) inside the mount namespace
- Predictable networking (or no external TCP dependencies)
- `CAP_SYS_ADMIN` and compatible LSM/seccomp setup

## Use cases

- **Container checkpoint for fast restart**: save state, resume later without re-initializing the process
- **Live migration**: pre-dump repeatedly, then final dump and restore elsewhere (used in container orchestration and HPC job migration)
- **Debugging "save a repro at crash time"**: checkpoint right before a failure for deterministic replay
- **CRaC (Java)**: [Coordinated Restore at Checkpoint](https://github.com/openjdk/crac) uses CRIU (or a CRIU-independent "Warp" engine introduced 2024) to snapshot a warmed-up JVM — reducing Spring Boot startup from ~4s to ~40ms
