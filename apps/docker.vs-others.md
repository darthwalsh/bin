#ai-slop 

How would you migrate off [[docker]] towards other components?

- **Docker Desktop** (Mac/Windows local VM + GUI)
    - OrbStack (faster, lighter, Mac-only)
    - Rancher Desktop (cross-platform, free)
- **Docker Hub** (public registry)
    - GitHub Container Registry (ghcr.io)
    - AWS ECR / Google AR / Azure ACR
- **Docker Engine** (the daemon / `dockerd`)
    - Podman (daemonless, rootless)
    - containerd (lower-level, what k8s uses directly)
- **Docker CLI** (`docker build`, `docker run`, etc.)
    - Podman CLI (drop-in compatible, `alias docker=podman` works)
    - nerdctl (containerd-native, also docker-compatible syntax)
- **Dockerfile / BuildKit** (image build format)
    - Buildah (OCI-native, scriptable)
    - Kaniko (build inside k8s without daemon)
- **Docker Compose** (`compose.yaml` orchestration)
    - Podman Compose (compatible but rougher edges)
    - kind / Tilt / Skaffold (if you're moving toward k8s-native dev)

The weakest alternative story is **Docker Desktop** — OrbStack is great but Mac-only, and nothing on Windows is as polished yet.
