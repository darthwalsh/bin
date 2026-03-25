Several linux resources are controlled by namespaces, allowing different containers to avoid collisions. These are useful for Docker, but also other OCI Containers.

Sources: [Wikipedia](https://en.wikipedia.org/wiki/Linux_namespaces), [less technical summary](https://www.redhat.com/sysadmin/7-linux-namespaces), [more technical with labs](https://web.archive.org/web/20241230090538/https://book.hacktricks.xyz/linux-hardening/privilege-escalation/docker-security/namespaces), [containers from scratch](https://ericchiang.github.io/post/containers-from-scratch/), [A Decade of Docker Containers](https://cacm.acm.org/research/a-decade-of-docker-containers/)

The 7 namespace types — each isolates a different class of kernel resource:

- **MNT** (mount points, 2001): each container sees its own filesystem tree. New mounts aren't shared by default. Related to `chroot` but operates at the kernel level rather than just path remapping. This is what makes a container's `/etc/passwd` different from the host's.
- **IPC** (inter-process communication, 2006): isolates [System V IPC](https://man7.org/linux/man-pages/man7/svipc.7.html) — message queues, semaphores, shared memory. Resource belongs to exactly one namespace.
- **NET** (network, 2007): each container gets its own network stack. Starts with only loopback; `containerd` wires up a virtual ethernet pair to connect it to the host. A resource belongs to exactly one namespace.
- **PID** (process IDs): PID 1 inside the container is treated as init. Processes have a PID in each namespace up the tree — the host can see the container's PID 1 as e.g. PID 4872.
- **USER** (user IDs): maps container UIDs to different host UIDs. Root (UID 0) inside a container can be mapped to an unprivileged UID on the host. All other namespaces are owned by a user namespace; parent namespaces can change child namespaces.
- **UTS** (hostname/domain name — the name "Unix Time-Sharing" is historical, not about time): lets each container have its own hostname without affecting the host.
- **TIME** (2020): lets a container see a different system clock offset.
- **CGROUP** (cgroup visibility): isolates which cgroup hierarchy a process sees. Distinct from cgroups themselves (see below).

## cgroups — resource limits, not isolation

[cgroups (control groups)](https://man7.org/linux/man-pages/man7/cgroups.7.html) predate namespaces and are a separate kernel feature. They don't isolate visibility — they enforce resource limits:
- CPU shares / quota, memory limits, disk I/O rate limits
- The kernel can OOM-kill all processes in a cgroup as a unit

Docker uses both: namespaces for isolation (what you can see), cgroups for limits (how much you can use).

## How Docker uses namespaces to start a container

- [ ] maybe this should move to [[docker.internals]]

When `docker run` is called, `containerd` creates a new set of namespaces and configures them:
1. **MNT**: mounts the OCI image layers (overlayfs) as the container's root filesystem
2. **NET**: creates a virtual ethernet pair — one end in the container's NET namespace, one end on the host bridge (`docker0`)
3. **PID**: the container's first process becomes PID 1 in its own PID namespace
4. **USER**: optionally remaps UIDs (e.g. container root → host UID 100000)
5. **UTS**: sets the container hostname
6. **IPC**: isolated message queues / shared memory
7. **CGROUP**: applies the resource limits from `docker run --memory`, `--cpus`, etc.

The namespace isolation applies only at resource *open* time. Once a file descriptor is open, subsequent reads/writes go through normal kernel paths with no extra overhead — this is why containers are fast compared to VMs.

## Namespace isolation is not a security boundary

Docker containers share the host kernel. There [exist](https://book.hacktricks.xyz/linux-hardening/privilege-escalation/docker-security/docker-breakout-privilege-escalation) several escapes from misconfigured containers and exploitable CVEs. A misconfigured container (e.g. `--privileged`, mounted `/var/run/docker.sock`, or writable host paths) can break out to the host.

For stronger isolation, see [[MicroVM]] (Firecracker, gVisor) which add a VM or syscall-interception boundary on top.
