# User mode vs kernel mode
Every modern OS splits CPU execution into (at least) two privilege levels.

| OS | User mode name | Kernel mode name | CPU mechanism |
|---|---|---|---|
| Linux / macOS (x86-64) | Ring 3 | Ring 0 | x86 protection rings |
| Windows (x86-64) | User mode | Kernel mode | x86 protection rings |
| ARM (all OSes) | EL0 | EL1 (kernel), EL2 (hypervisor) | ARM Exception Levels |

## CPU vs. OS enforcement
When a process calls `open("/etc/shadow")`, the CPU doesn't decide yes/no — it just switches to kernel mode at the syscall boundary, and then the kernel checks the calling process's credentials against the file's ACL.

The CPU enforces mode separation: user-mode code cannot execute privileged instructions, cannot directly access kernel memory, cannot issue privileged I/O.

## The syscall boundary
The only sanctioned way to ask the kernel to do something is a **system call** (syscall). The calling convention differs by CPU and OS, but the transition is the same:

1. User-mode code places arguments in registers and executes a trap instruction (`syscall` on x86-64, `svc` on ARM)
2. CPU switches to ring kernel mode and jumps to the kernel's entry point
3. Kernel executes the requested operation (checking credentials, ACLs, etc.)
4. Kernel places the return value in a register and returns to user mode

The process's security identity (root vs non-root changed by [[sudo]]) doesn't changes this flow. Root (UID 0) just gets more operations approved by the kernel's policy checks.

See [[os-syscall-interfaces]] for how user-mode libraries (glibc, Win32, libSystem) wrap this boundary.

## Kernel-mode code
Kernel-mode code is: the OS kernel itself, device drivers, kernel modules (Linux `.ko`), Windows kernel-mode drivers (`.sys`), hypervisors. These run at ring 0 / EL1 and have unrestricted hardware access. Crashes here take down the whole machine (kernel panic / BSOD). See [[programming.environments]] for the development implications.

eBPF programs (Linux) are an interesting exception: they are verified and JIT-compiled code that runs in kernel mode but with strict constraints.
