#ai-slop
Docker containers require a Linux kernel. On macOS and Windows, Docker Desktop embeds a Linux VM so the same `docker build` / `docker run` workflow "just works." Source: [A Decade of Docker Containers (ACM, 2026)](https://cacm.acm.org/research/a-decade-of-docker-containers/)

## The embedded Linux VM approach

The key design decision: instead of running Linux *alongside* the desktop OS (like VMware Fusion), Docker embeds the hypervisor *inside* a normal userspace application. The Linux VM is an implementation detail of the Docker Desktop app, not a separate machine to manage.

Components:
- **HyperKit** (macOS): a [library VMM](https://github.com/moby/hyperkit) that uses Intel VT-x hardware virtualization extensions to run a Linux kernel as a normal macOS process. On Apple Silicon, replaced by Apple's [Virtualization.framework](https://developer.apple.com/documentation/virtualization).
- **LinuxKit**: a custom minimal Linux distro purpose-built to be embedded. Every component (including `dockerd`) runs inside a container; nothing runs in the root namespace at boot. This lets LinuxKit itself use the same copy-on-write filesystems and network namespaces that containers use.
- **WSL2** (Windows): Microsoft adopted the same embedded-Linux approach in 2018. Docker for Windows runs `dockerd` inside a LinuxKit WSL2 distribution and forwards the Docker API and network ports to Windows.

The combination boots a Linux process almost as fast as a native macOS process.

## Networking: why bridging doesn't work and what SLIRP does instead

The naive approach — bridging the Linux VM's ethernet directly to the desktop network stack — triggers corporate firewalls and virus scanners, which flag traffic from unknown processes bypassing the host OS network stack.

Docker's solution uses [SLIRP](https://en.wikipedia.org/wiki/Slirp), originally used to connect PalmPilot PDAs to the internet in the mid-1990s:

**Outgoing traffic** (container → internet):
1. Container sends a TCP SYN; an ethernet frame is sent to the host over [virtio](https://wiki.osdev.org/Virtio) shared memory.
2. **vpnkit** (a userspace TCP/IP stack written in OCaml, from the [MirageOS](https://mirage.io/) unikernel project) receives the frame and calls the macOS `connect()` syscall.
3. From the VPN/firewall's perspective, traffic originates from the Docker Desktop *application process*, not from an unknown VM — no false positives.

**Incoming traffic** (localhost port forwarding):
- `docker run --publish 8080:80` should make the container reachable at `http://localhost:8080` on the Mac — not at some intermediate VM IP.
- LinuxKit installs a custom [eBPF](https://ebpf.io/) program that detects when a container starts listening on a port and creates a corresponding socket on the macOS host, with a port forwarder bridging them transparently.

## Filesystem: virtio-fs and bind mounts

`docker run --volume /host/path:/container/path` requires the container (inside the Linux VM) to access files on the macOS filesystem. Since macOS and Linux are different kernels, Linux bind mounts don't work directly.

Docker uses [virtio-fs](https://virtio-fs.gitlab.io/) — a shared memory protocol originating from the KVM hypervisor — to send filesystem operations from the Linux VM to the macOS host as [FUSE](https://en.wikipedia.org/wiki/Filesystem_in_Userspace) requests. The host receives them and invokes the corresponding `open`/`read`/`write` syscalls.

This keeps the developer's files on the macOS filesystem, so tools like Time Machine and Spotlight still work on them.

Gotcha: virtio-fs adds latency compared to native Linux bind mounts. For hot paths (e.g. `node_modules` inside a container), this is why Docker Desktop recommends keeping source files inside the Linux VM's own filesystem rather than mounting from macOS.

## Multi-architecture builds (Intel ↔ ARM)

OCI images support [multiarch manifests](https://docs.docker.com/build/building/multi-platform/) — a single image tag can record builds for multiple CPU architectures (amd64, arm64, RISC-V, etc.).

Building for a *different* architecture without cross-compilation: LinuxKit includes [QEMU](https://www.qemu.org/) and registers it with [`binfmt_misc`](https://docs.kernel.org/admin-guide/binfmt-misc.html), a Linux kernel feature that lets executables be run through a custom userspace interpreter. When `docker buildx` builds an ARM image on an Intel Mac, the ARM binaries are transparently run through QEMU's CPU instruction translation.

Apple Silicon Macs use [Rosetta 2](https://developer.apple.com/documentation/apple-silicon/about-the-rosetta-translation-environment) for the same purpose when running Intel containers natively.

## WSL2 on Windows

WSL1 (2017) used syscall translation (no VM) — not enough Linux kernel coverage to run Docker containers. WSL2 (2018) runs a full Linux VM in the background, same approach as Docker for Mac.

Docker for Windows with WSL2:
- `dockerd` and containers run inside a LinuxKit WSL2 distribution
- Docker API and network ports are forwarded to both Windows itself and other WSL2 Linux distributions
- No separate HyperKit needed — Hyper-V provides the VM capability

See also: [[MicroVM]] for how this embedded-VM approach compares to Firecracker and full VMs.
