#ai-slop
## MicroVMs: where Firecracker fits between containers and "traditional VMs"

If you're trying to reason about **cold starts**, **isolation**, **compatibility**, or **"what am I really running on?"**, you'll get better answers by separating these layers:

- **Hardware virtualization** (VMs, microVMs): strong isolation boundary, but you boot a kernel.
- **OS-level isolation** (containers): fast, but shared kernel.
- **Sandboxed OS-level isolation** (gVisor): still containers, but with an extra sandbox boundary.
- **Language-runtime isolation** (V8 isolates / WASM): extremely fast, but with big API/runtime constraints.

This note is mostly about **Firecracker microVMs** and how they show up in real platforms (AWS, GCP, Fly.io, edge runtimes).

---

## The isolation spectrum (fast ↔ compatible)

### Containers - e.g. docker
**What it is**: processes isolated by [[LinuxNamespaces]] and cgroups; **shared host kernel**.
**Why it's fast**: no guest kernel boot; "start a process" is the unit of work.
**Trade-offs**: weakest tenant boundary of the options here (because kernel is shared).

When do you need this?
- Fast startup for long-running services.
- High compatibility with Linux user-space.

NOT suitable for multi-tenant "run untrusted code" unless you add stronger sandboxing.

#### Examples

- **AWS ECS on EC2**: container isolation on a shared instance kernel (unless you add sandboxing yourself).

### Sandboxed containers - e.g. gVisor
**What it is**: containers, but system calls are mediated by a **userspace kernel** ([gVisor](https://gvisor.dev/)) rather than going directly to the host kernel.

**Why it exists**: "stronger than plain containers" without booting a whole VM per workload.
**Trade-offs**: some syscalls/features are slower/unsupported; debugging can feel different than "real Linux".

Common limitations you'll run into (varies by platform/config):
- **Syscall compatibility gaps**: unusual/low-level syscalls may be blocked or behave differently.
- **Kernel-adjacent features**: eBPF, kernel modules, privileged containers are generally not available.
- **Performance profile**: syscall-heavy workloads can pay noticeable overhead.

Gotcha: gVisor can break "clever Linux tricks". Anything that assumes deep kernel feature access may fail or degrade, so test early on gVisor-based platforms if you rely on kernel internals.

When do you need this?
- You want "container UX" but the provider needs stronger multi-tenant isolation.
- Your workload is mostly HTTP + language runtime + normal file/network I/O.

#### Examples

- **GCP Cloud Run**: container runtime with a gVisor-based sandbox in the fully managed product.
- **GCP Cloud Functions Gen 2**: built on top of Cloud Run.

### MicroVMs  - e.g. Firecracker
**Firecracker** is a minimal virtual machine monitor (VMM) built on KVM, designed to run **many tiny VMs** efficiently.
The big idea: **keep VM isolation**, remove most of the "general purpose VM" surface area.

Implementation constraint that’s easy to miss: **Firecracker runs on a Linux host** because it relies on **KVM** (a Linux kernel virtualization subsystem). So you have a Linux host running the VMM process, and then a (typically Linux) guest kernel inside the microVM.

Gotcha: microVM does not mean "no kernel". Firecracker microVMs boot a real guest Linux kernel; they're just typically paired with a minimal rootfs and minimal init to keep startup and overhead low.

Gotcha: a container image is still "just packaging". Your Dockerfile can build and run fine, but a microVM-based runtime can still be more constrained than "Docker on my own servers" because execution happens inside the provider's isolation layer.

When do you need this?
- Multi-tenant workloads where you want a VM boundary but "container-like density".
- Serverless / short-lived compute where boot time matters.
- "I want to run a container image, but with VM isolation."

#### Traditional VM (QEMU-like device model) vs Firecracker
Boot/startup time
- **Traditional VM**: often "seconds-ish" (full firmware/boot path + lots of virtual devices).
- **Firecracker**: AWS's original Firecracker launch materials cite **~125ms** boot in ideal conditions.

Device model / compatibility
- **Traditional VM**: wide device emulation; supports more guest OS expectations.
- **Firecracker**: intentionally tiny device set (virtio-style devices); no graphics/USB/BIOS-like world.

##### Processes running on Firecracker
- **On the host**: there is typically **one `firecracker` VMM process per microVM** (often started via the `jailer` helper). The `jailer` exists to reduce blast radius by putting the VMM in a tight sandbox (seccomp filtering, cgroups, chroot-like filesystem isolation).
- **Inside the guest**: after the kernel boots, PID 1 is whatever you shipped as init (often a tiny init + your runtime/app). The guest can be a full distro, but Firecracker is commonly paired with a minimal rootfs and minimal init.

##### Limitations
**Fewer "it just works" assumptions** if your software expects lots of devices/udev behavior
- **No GUI / desktop expectations**
- **No hardware passthrough** in the way "full VMs" can support (GPU/USB, etc.)
- Not suitable if you need "full Linux kernel feature access" (e.g., special filesystem/kernel tricks).
- Not suitable for hardware/device-heavy workloads.
- Not suitable for non-Linux guests. The host must be Linux (KVM), but that Linux host can itself run inside a larger VM on Windows/macOS if [[NestedVirtualization]] is enabled (i.e., the guest has access to `/dev/kvm`).

#### Examples

- **AWS Lambda**: execution environments are isolated using Firecracker microVMs.
- **AWS ECS on Fargate**: commonly documented as “container UX” with a Firecracker microVM per task.
- **Fly.io Machines**: microVM-first runtime (Firecracker-based).

### Full VMs (traditional virtualization)
This is the "classic" model: a guest OS running under a general-purpose hypervisor, typically with broader device/firmware expectations than microVMs.

Technologies commonly associated with full VMs:
- **KVM + QEMU** (Linux hosts)
- **Xen** (common in older clouds and some private virtualization stacks)
- **Microsoft Hyper-V** (Windows Server / Windows)
- **VMware ESXi** (bare-metal hypervisor)
- **bhyve** (FreeBSD)

#### Examples

- **AWS EC2 (most instance types)**: [AWS Nitro](https://aws.amazon.com/ec2/nitro/) is a KVM-based hypervisor, so typical EC2 instances are full VMs (bare-metal instance types are the exception).

#### Hypervisor types
- **Type 1 (bare-metal)**: the hypervisor runs directly on the hardware. The host OS (if present) is effectively a special guest/partition managed by the hypervisor.
- **Type 2 (hosted)**: the hypervisor/VMM runs as a process on top of a normal host OS, typically using hardware virtualization (VT-x/AMD-V) for performance.

**MicroVM-style VMMs** are usually built on top of a Type 1 capability like KVM.

Virtualization products:

**Windows**
- **Hyper-V**: Type 1 (bare-metal), even though you manage it from Windows. Built-in, first-party Windows integration.
- **Windows Sandbox**: Type 1 (Hyper-V based). Fast disposable Windows environment for testing.
- **VMware Workstation**: Type 2 (hosted). Polished “pro” desktop VM experience and tooling.
- **VirtualBox**: Type 2 (hosted). Widely used OSS option for cross-platform desktop VMs.

**macOS**
macOS desktop virtualization is typically **Type 2 (hosted)** (apps run on top of macOS and use Apple’s hypervisor APIs for acceleration).
- **Parallels Desktop**: tight macOS integration for running Windows/Linux locally.
- **VMware Fusion**: fits the VMware ecosystem (and common in existing VMware shops).
- **UTM** (UI around QEMU): approachable GUI for QEMU, popular for OSS workflows.
- **VirtualBox**: legacy/cross-platform option (most common on Intel Macs).

**Linux**
- **KVM + QEMU**: Type 1 capability (KVM) with a userland VMM (QEMU). “Native” Linux virtualization stack.
- **virt-manager**: UI for managing KVM/QEMU VMs on Linux (Type 1 capability via KVM).
- **GNOME Boxes**: Simpler “click-to-run” UI for KVM/QEMU on Linux (Type 1 capability via KVM). 
- **Proxmox VE**: Type 1 capability (KVM) with a server-focused management layer (installed as a Linux-based appliance).
- **VMware Workstation**: Type 2 (hosted). Commercial desktop VM tooling on Linux.
- **VirtualBox**: Type 2 (hosted). Familiar cross-platform tooling.

Server-focused:
- **VMware ESXi**: Type 1 (bare-metal). Common enterprise virtualization platform.
- **XCP-ng / Citrix Hypervisor (Xen)**: Type 1 (bare-metal). Common Xen-based bare-metal virtualization option.

When do you need this?
- You need broad guest OS support (including non-Linux) and "normal VM" expectations.
- You need features and devices that minimalist VMMs intentionally omit.

### Language isolates and WASM (edge compute)
This is "microVM adjacent" in motivation (fast + isolated) but **not a VM**.

#### V8 isolates (Cloudflare Workers, Deno-style edge)
- **What it is**: multiple "isolated" JS runtimes inside one process.
- **Why it's fast**: no VM boot, often no container start; instantiate an isolate and run JS.
- **Typical constraints**:
    - no arbitrary native binaries
    - no general-purpose filesystem
    - limited networking model (often fetch-style HTTP rather than raw sockets)

#### WebAssembly sandboxes (Fastly Compute@Edge, etc.)
- **What it is**: WASM modules with a capability-based host API.
- **Strength**: strong sandboxing model + portability.
- **Constraints**: you live within the WASM host API surface.

When do you need this?
- Ultra-fast "run code near users" request handlers.
- You accept platform APIs/limits in exchange for latency + scale.
- Not suitable if you need arbitrary OS access.

#### Examples

- **Cloudflare Workers**: V8 isolates (not containers, not VMs).
- **Vercel Edge Functions**: “edge runtime” model
- **Netlify Edge Functions**: similar “edge runtime” story.
- **Fastly Compute@Edge**: WebAssembly runtime model.

### Debugging and observability gotcha

The tighter the sandbox, the less you can "ssh in and poke around". Plan to rely more on logs, metrics, tracing, and platform-provided debugging tools than interactive shell access.

### Unspecified technology
If a platform/tool doesn’t clearly map to one of the buckets above, park it here until I find a primary-source description of its execution boundary:

- **Heroku**: closer to "dynos/containers on managed hosts" than an explicit VM-per-workload guarantee.
- **Render**: closer to "services/containers on managed hosts" than an explicit VM-per-workload guarantee.
- **Railway**: closer to "containers on managed hosts" than an explicit VM-per-workload guarantee.
- **GCP App Engine Standard**: a restricted runtime sandbox with platform constraints (doesn’t neatly match the buckets above).
