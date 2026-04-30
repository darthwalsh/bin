#ai-slop

A Dev Container runs your development environment inside a Docker container locally. Your editor UI stays on the host; all tools, runtimes, and terminals execute inside the container.

## Dev Containers vs Codespaces

Both use the same `.devcontainer/devcontainer.json` config format, but differ in where they run:

| | Dev Containers | Codespaces |
|---|---|---|
| Where it runs | Local Docker on your machine | Cloud VM (GitHub-hosted) |
| Startup time | Seconds (image already pulled) | ~30–60s first boot |
| Cost | Your hardware | Per-minute billing |
| Offline access | Yes | No |

## Running a Linux dev environment from Mac

macOS runs Darwin (XNU kernel). If your target environment is Linux — different syscall behavior, paths, package managers — run your toolchain inside a Linux container:

1. Add a `.devcontainer/` folder to the repo root.
2. Set a Linux base image in `devcontainer.json`:
```json
{
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu"
}
```
3. Open the folder in your editor; it will prompt to reopen in the container.

Your editor UI stays on macOS, but every terminal, build, and test runs inside Linux. See [[docker.desktop]] for how Docker Desktop bridges macOS ↔ Linux (virtio-fs bind mounts, SLIRP networking).

## Workspace mounting and the client/server split

When you attach to a container, the workspace folder is bind-mounted into the container filesystem. You edit files locally; the container sees the same bytes live.

```
macOS host                    Linux container
 ~/projects/myrepo  ←bind→   /workspaces/myrepo
 Editor UI (local)            All terminals, compilers, daemons
```

This is why Cursor describes it as client/server: the UI is the client, the container is the server. Opening in a new Cursor window and "Attach to Container" gives the same split explicitly.

Gotcha from [[docker.desktop]]: virtio-fs adds latency on hot paths (e.g. `node_modules`). For performance-sensitive builds, keep build artifacts inside the container volume rather than the mounted source tree.
