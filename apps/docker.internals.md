#ai-slop
How Docker works on a Linux host (or inside the Linux VM on macOS/Windows). This covers the daemon architecture, image storage, and how the CLI talks to running containers. Source: [A Decade of Docker Containers (ACM, 2026)](https://cacm.acm.org/research/a-decade-of-docker-containers/)

For namespace/cgroup isolation mechanics, see [[LinuxNamespaces]].
For macOS/Windows VM bridging, see [[docker.desktop]].

## Client-server architecture: the Docker socket

Docker is a client-server application. The `docker` CLI never directly creates containers — it sends API calls to the `dockerd` daemon over a Unix domain socket at `/var/run/docker.sock`.

```
docker CLI  →  /var/run/docker.sock  →  dockerd  →  containerd  →  runc (container process)
```

- **`dockerd`**: the main daemon. Accepts API calls, manages high-level concepts (images, networks, volumes). Delegates actual container lifecycle to `containerd`.
- **`containerd`**: manages container lifecycle — pulling images, creating snapshots, starting/stopping containers. Runs as a separate process; can be used independently of Docker (e.g. Kubernetes uses it directly).
- **`runc`**: the low-level OCI runtime that actually calls `clone()` with the namespace flags and `execve()`s the container process. `containerd` spawns `runc` per container start, then `runc` exits — the container process is now a direct child of `containerd`.
- **`buildkit`**: handles `docker build`. Separate from the runtime path; introduced ~2018 to replace the old builder inside `dockerd`.

Gotcha: mounting `/var/run/docker.sock` into a container gives that container full control over the Docker daemon — equivalent to root on the host. This is a common CI pattern (`docker-in-docker` alternatives) but a significant security risk.

## Image storage: content-addressable layers

A Docker image is a stack of read-only filesystem layers. Each layer is the diff produced by one Dockerfile instruction (`RUN`, `COPY`, etc.).

- Layers are stored by their SHA256 hash — the hash *is* the key. Identical layers (e.g. the same base `FROM python:3` across 10 images) are stored once and shared.
- The [OCI image format](https://github.com/opencontainers/image-spec) (standardized 2016) defines this layout. Multiple runtimes (Docker, Podman, containerd, etc.) can read the same image.
- On disk, Docker uses [overlayfs](https://docs.kernel.org/filesystems/overlayfs.html) (or btrfs/ZFS) to stack the layers. overlayfs presents a merged view: reads fall through to lower layers, writes go to a per-container writable layer on top.
- `docker pull` only downloads layers not already present locally — deduplication is automatic.
- `docker build` caches each layer. If a layer's inputs haven't changed, the cached layer is reused. This is why instruction order in a Dockerfile matters for build speed.

```
Container writable layer  (ephemeral, discarded on docker rm)
────────────────────────
Layer N  (COPY . /app)
Layer N-1  (RUN pip install -r requirements.txt)
Layer N-2  (COPY requirements.txt /app/)
Layer 1  (FROM python:3  — shared with other images using this base)
```

## How `docker run` starts a container

1. `dockerd` receives the `POST /containers/create` + `POST /containers/{id}/start` API calls.
2. `containerd` pulls the image if not present, then creates a snapshot (an overlayfs mount) for the container's writable layer.
3. `containerd` calls `runc` with an OCI runtime spec — a JSON file describing the namespaces, cgroups, mounts, and the process to exec.
4. `runc` calls `clone()` with the namespace flags, sets up cgroups, mounts the overlayfs root, then `execve()`s PID 1 inside the new namespaces.
5. `runc` exits. The container process is now running, supervised by `containerd`.

The container process appears in `ps` on the host with its real PID, but inside the container it sees itself as PID 1.

## Container networking on a Linux host

By default, Docker creates a bridge network (`docker0`) on the host:
- Each container gets a virtual ethernet pair (`veth`): one end inside the container's NET namespace, one end attached to `docker0` on the host.
- `dockerd` manages NAT rules (via iptables/nftables) so containers can reach the internet through the host's network interface.
- `docker run --publish 8080:80` adds a DNAT rule: traffic arriving at host port 8080 is forwarded to the container's port 80.

User-defined networks (`docker network create`) use the same veth+bridge mechanism but give containers DNS resolution by name (e.g. a container can reach another at `http://my-service:80`).

## Volumes vs bind mounts

- **Volumes** (`docker volume create`): managed by Docker, stored under `/var/lib/docker/volumes/`. Survive `docker rm`. Preferred for persistent data.
- **Bind mounts** (`--volume /host/path:/container/path`): a host directory grafted into the container's MNT namespace. The container sees the live host filesystem at that path. Used for development (mount source code in) and for sharing config/secrets.
- **tmpfs mounts**: in-memory only, discarded on container stop. Useful for secrets that shouldn't touch disk.

## Secrets management

Baking secrets into image layers is dangerous — they're visible in `docker history` and in the registry. Options:
- **Build secrets** (`docker build --secret`): passed to `RUN` steps via a tmpfs mount, not stored in any layer.
- **Runtime secrets** (Docker Swarm / Kubernetes): injected as files at container start, not in the image.
- **Socket forwarding**: `ssh-agent` and similar key managers can be forwarded into a container via a Unix socket mount, so the key never enters the container's filesystem.
- **Trusted Execution Environments (TEEs)**: hardware-level enclaves (Intel TDX, AMD SEV) that protect secrets from even the host OS. The [Confidential Containers](https://confidentialcontainers.org/) project integrates TEEs with the OCI/containerd stack.
