#ai-slop
Docker's checkpoint/restore feature wraps [[criu]] to freeze and resume containers. It's **experimental** and has been since Docker 1.13 (2016). The key constraint: CRIU must be installed on the host where the Docker daemon runs, not inside the container.

See [[snapshots]] for how process checkpointing compares to filesystem snapshots and debugger record/replay.

## Status and commands

Enable experimental in `/etc/docker/daemon.json`:

```json
{"experimental": true}
```

Then:

```bash
docker checkpoint create <container> <checkpoint-name>
docker start --checkpoint <checkpoint-name> <container>
docker checkpoint ls <container>
docker checkpoint rm <checkpoint-name> <container>
```

Known limitations from [Docker docs](https://docs.docker.com/reference/cli/docker/checkpoint/):
- Containers started with `-t` (TTY) don't checkpoint reliably
- Often requires `--security-opt=seccomp:unconfined` to get past seccomp compatibility issues
- External TCP connections will not survive (see [[criu#What breaks]])

## Docker Desktop on macOS and Windows: not supported

Verified: Docker Desktop 29.x (macOS) runs a **LinuxKit VM** (`6.12.76-linuxkit`, Alpine 3.23) that does **not include CRIU**. Checking both inside containers and at the VM's host level confirms `criu` is not in `$PATH`. The `docker checkpoint` command returns:

> docker checkpoint is only supported on a Docker daemon with experimental features enabled

Even if you enabled experimental features, CRIU would still be absent from the LinuxKit image. The [GitHub issue tracking this](https://github.com/docker/for-mac/issues/1059) has been open since 2016 with no resolution.

**The root cause**: Docker Desktop's LinuxKit VM is a managed, read-only environment that Docker Inc. controls. You can't `apt install criu` into it.

## Linux engine you control: the working path

On a real Linux host (or Docker Engine installed directly inside a WSL2 distro), you control the daemon and its host environment:

```bash
# Install CRIU (Debian/Ubuntu)
sudo apt-get install criu

# Enable experimental in the daemon config
sudo mkdir -p /etc/docker
echo '{"experimental": true}' | sudo tee /etc/docker/daemon.json
sudo systemctl restart docker

# Verify
docker info | grep -i experimental
criu check
```

Then `docker checkpoint` works as documented.

## WSL2 path: Docker Engine inside Ubuntu WSL

If you're on Windows and want CRIU-compatible checkpoint/restore, run Docker Engine *inside your Ubuntu WSL distro* rather than using Docker Desktop:

1. Install `docker-ce` inside your Ubuntu WSL distro (not Docker Desktop):

```bash
# Inside Ubuntu WSL
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
```

2. Enable experimental and install CRIU:

```bash
echo '{"experimental": true}' | sudo tee /etc/docker/daemon.json
sudo apt-get install criu
sudo service docker start
```

3. Verify with `docker info | grep Experimental` and `criu check`.

The key: when Docker Engine runs inside your Ubuntu WSL distro, the daemon's host environment *is* your Ubuntu WSL — so CRIU installed there is in the right place. When Docker Desktop's daemon runs inside its own managed LinuxKit distro, CRIU installed in your Ubuntu WSL is in the wrong place.

Gotcha: checkpoint compatibility still depends on what your container is actually doing — TTY, GPU access, or external TCP will still fail per CRIU's normal limitations.

## macOS path: no direct equivalent

On macOS there is no practical path to Docker checkpoint/restore:

- Docker Desktop's LinuxKit VM doesn't include CRIU and can't be modified
- There is no equivalent to "run Docker Engine natively" on macOS (Docker always goes through a Linux VM)
- For the "experiment and revert" use case on macOS, use [[snapshots#Debugger record/replay|`rr` inside a Linux container]] or VM snapshots at the VM level

## Podman as alternative

[CRIU's own docs](https://criu.org/Docker) increasingly recommend Podman for checkpoint/restore workflows. Podman's checkpoint/restore is better documented and more actively maintained:

```bash
# Checkpoint
podman container checkpoint --leave-running --export=/tmp/checkpoint.tar.gz <container>

# Restore (same host or a different one)
podman container restore --import=/tmp/checkpoint.tar.gz
```

The `--export` / `--import` flags make portable checkpoint images that can be moved between hosts, which maps well to live migration workflows.
