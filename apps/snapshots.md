#ai-slop
Three different technologies get called "snapshot" in container/VM/debugging contexts. They solve different problems and don't compose cleanly:

| Type | What's saved | Restores to | Platform |
|------|-------------|-------------|----------|
| Filesystem/data snapshot | Disk state (container layers, volumes, DB) | Same data, new process | Any |
| Process execution snapshot | Memory + CPU + kernel objects | Running process, resumed mid-execution | Linux (CRIU) or hypervisor VMs |
| Debugger record/replay | Execution trace | Replay / reverse-step through a recording | Linux `rr`, Windows TTD |

## Filesystem/data snapshot

Saves what's on disk, not RAM or CPU state. The process is not "paused" — you get a consistent disk view, not a consistent execution view.

- **`docker commit`**: creates a new image from the container's current writable layer. Captures installed packages, config file edits, etc. Does not preserve any in-memory state.
- **Volume snapshots**: snapshot the underlying storage (ZFS, EBS, LVM snapshot, etc.) for persistent data. Used for database backups before risky migrations.
- **DB-native snapshots**: `pg_dump`, MySQL snapshot isolation — consistent view of DB state at a point in time without freezing the process.

When to use: "I want to roll back to a known good filesystem state" or "I want to restore a database backup."

## Debugger record/replay

Records execution so you can replay it deterministically and step backwards. The program actually ran — side effects already happened to the outside world — but you can re-examine the execution trace.

### `rr` (Linux / WSL2)

[`rr`](https://rr-project.org/) records a process execution and lets you replay it with gdb, including reverse-continue and reverse-step. The key insight: record once, replay as many times as needed.

- Best for: C/C++ and other native code, reproducing intermittent bugs
- Works in Docker containers (run the container with `--cap-add=SYS_PTRACE` and appropriate `perf_event_paranoid` setting)
- WSL2: [reportedly works for many users](https://github.com/rr-debugger/rr/issues/2506) but depends on WSL kernel version and perf counter support

### WinDbg TTD (Windows)

[Time Travel Debugging](https://learn.microsoft.com/en-us/windows-hardware/drivers/debuggercmds/time-travel-debugging-overview) in WinDbg records a `.run` trace file you can step forward/backward through in WinDbg. Ships with WinDbg Preview.

- Best for: Windows native processes, kernel debugging
- Also available for live ASP.NET apps on Azure VMs via Visual Studio Enterprise (see below)

### Azure Time Travel Debugging + Snapshot Debugger

Visual Studio Enterprise integrates two related tools for Azure VM–hosted ASP.NET apps:

- **[Snapshot Debugger](https://learn.microsoft.com/en-us/visualstudio/debugger/debug-live-azure-virtual-machines)**: attaches to a live Azure VM and captures application state at a **snappoint** (like a non-halting breakpoint) without stopping execution. Snapshot appears in Application Insights and can be downloaded as a `.diagsession` for offline inspection.
- **[Time Travel Debugging on Azure VMs](https://learn.microsoft.com/en-us/visualstudio/debugger/debug-live-azure-virtual-machines-time-travel-debugging)**: records the execution of a live ASP.NET app and lets you replay it with forward/backward stepping in Visual Studio.

Both require Visual Studio Enterprise and are scoped to ASP.NET on Azure VMs/VMSS — not general-purpose process recording.

### IntelliTrace Step-Back (Visual Studio)

[IntelliTrace](https://learn.microsoft.com/en-us/visualstudio/debugger/view-snapshots-with-intellitrace) captures snapshots at every breakpoint and debugger step so you can navigate backward through your debugging session without restarting. Available in Visual Studio Enterprise for .NET apps.

## Process execution snapshot (CRIU — Linux only)

See [[criu]] for the full mechanics. The short version: freeze the process, serialize memory + CPU state + kernel objects to disk, restore later as if nothing happened.

- **Scope**: Linux only. [[docker-checkpoint]] covers how this applies to containers.
- **Hypervisor VMs**: hypervisors have their own equivalent — see below.

### Hypervisor VM live migration

Hypervisors migrate a running VM across hosts using a **pre-copy** approach that's conceptually similar to CRIU's pre-dump but operates at the VM level rather than the process level:

1. **Pre-copy phase**: iteratively transfer guest RAM to the destination while the VM keeps running; the hypervisor tracks [dirty pages](https://criu.org/Memory_changes_tracking) (pages written since the last copy round)
2. **Stop-and-copy**: pause the VM, transfer remaining dirty pages + CPU state + device state
3. **Handoff**: VM resumes on the destination host

Target downtime is typically under 100ms of guest-perceived pause. Shared or replicated storage for VM disk is a prerequisite (the disk doesn't move during live migration, only RAM + CPU state does).

#### Examples

- **[VMware vMotion](https://blogs.vmware.com/cloud-foundation/2019/07/09/the-vmotion-process-under-the-hood)**: the original commercial live VM migration. Tracks dirty pages via hardware memory protection; later versions (vSphere 7.0 U1+) added bitmap and large-page optimizations.
- **[KVM/QEMU migration](https://www.qemu.org/docs/master/devel/migration/main.html)**: built into QEMU. Multiple transport options (TCP, Unix socket, RDMA). Dirty page tracking via `KVM_GET_DIRTY_LOG` (bitmap) or dirty ring (kernel 5.11+, lower overhead). Used by OpenStack Nova for VM migration between compute nodes.
- **[KubeVirt](https://kubevirt.io/user-guide/compute/live_migration/)**: adds live VM migration to Kubernetes for workloads that need full VMs. Requires `ReadWriteMany` PVC access mode for the VM disk.
- **Hyper-V Live Migration**: Windows Server equivalent, integrated with Failover Cluster Manager.

#### CRIU vs hypervisor live migration

| | CRIU (process/container) | Hypervisor live migration |
|---|---|---|
| Granularity | Single process tree or container | Entire VM |
| Requires shared storage | No (images on disk, moved separately) | Usually yes (for VM disk) |
| Kernel compatibility | Sensitive (same kernel version often required) | Guest kernel is opaque to hypervisor |
| External TCP | Fragile | Transparent (guest retains IP/sockets) |
| Typical downtime | Seconds (pre-dump) to minutes | Under 100ms |
| Who uses it | Container orchestration, HPC | Datacenter host maintenance, HA |

The hypervisor approach is easier when migrating whole VMs because the guest kernel is opaque — the hypervisor just moves RAM + CPU state, it doesn't need to understand the process's kernel objects. CRIU has to understand and recreate every kernel object individually.
