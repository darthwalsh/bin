#ai-slop
# Docker BuildKit Cache

All examples assume modern Docker with BuildKit/buildx available (default since Docker 23+). Legacy `DOCKER_BUILDKIT=1` env var and `docker-compose` v1 are not needed.

## Cache Modes: Inline vs Registry

**Registry cache (`--cache-to type=registry,mode=max`) is preferred** for CI↔local sharing — it exports a richer, separate cache artifact that survives image overwrites.

**Inline cache (`BUILDKIT_INLINE_CACHE=1`)** embeds cache metadata inside the image tag itself. Simpler mental model, but cache is coupled to the image tag lifecycle and captures less intermediate state.

| | Inline | Registry (`mode=max`) |
|---|---|---|
| Storage | Inside the pushed image | Separate registry artifact |
| Coverage | Final image layers only | All intermediate layers |
| Best for | Simple single-tag workflows | CI↔local, PR isolation |
| Use with | `--cache-from=REGISTRY/img:tag` | `--cache-from=type=registry,ref=…` |

`mode=min` (the default for registry export) only captures what's needed to reproduce the final image; `mode=max` captures all intermediates — use `max` when you want "only a later RUN changed" to still hit cache.

## CI Pattern

CI builds, exports cache, and pushes the image in one command:

```bash
REGISTRY=artifactory.example.com
IMAGE=$REGISTRY/myteam/myapp:main
CACHE=$REGISTRY/myteam/myapp:buildcache

docker buildx build \
  --tag "$IMAGE" \
  --push \
  --cache-to="type=registry,ref=$CACHE,mode=max" \
  --cache-from="type=registry,ref=$CACHE" \
  .
```

No separate `docker buildx create` step needed unless `docker buildx ls` shows no usable builder.

## Compose Pattern

`cache_from` in `compose.yaml` is stable. `cache_to` is in the [Compose spec](https://docs.docker.com/reference/compose-file/build/#cache_to) but silently ignored on older builders — verify with `BUILDKIT_PROGRESS=plain docker compose build` and look for "exporting cache" lines.

**Base `compose.yaml`** (used everywhere — local + CI):

```yaml
services:
  app:
    build:
      context: .
      cache_from:
        - type=registry,ref=artifactory.example.com/myteam/myapp:buildcache
```

**CI overlay `compose.ci.yaml`** (adds cache export, only run in Jenkins):

```yaml
services:
  app:
    build:
      cache_to:
        - type=registry,ref=artifactory.example.com/myteam/myapp:buildcache,mode=max
```

```bash
# Jenkins
docker compose --file compose.yaml --file compose.ci.yaml build

# Local
docker compose build
```

> Compose calls Docker APIs directly — there's no way to dump the equivalent `docker buildx` command it generates.

## Multi-Ref `cache_from`: PR + Main Branch Isolation

Using the same cache ref for `cache_from` and `cache_to` across all branches works, but PR builds can push a cache snapshot that's less aligned with `main`. Better:

| Branch | `cache_from` | `cache_to` |
|---|---|---|
| `main` | `buildcache-main` | `buildcache-main` |
| PR | `buildcache-pr-123`, `buildcache-main` | `buildcache-pr-123` |
| Local | `buildcache-main` | _(nothing)_ |

Multiple `cache_from` entries work as a set union — BuildKit tries all sources and picks the best match. A missing cache ref logs `failed to import cache: not found` and continues without error.

Compose example for a PR build:

```yaml
cache_from:
  - type=registry,ref=artifactory.example.com/myteam/myapp:buildcache-pr-123
  - type=registry,ref=artifactory.example.com/myteam/myapp:buildcache-main
```

Watch out for concurrent CI jobs writing the same cache ref simultaneously — BuildKit has [known oddities](https://github.com/moby/buildkit/issues/6418) with multiple concurrent writers. Serialize cache-writing jobs or use branch-scoped refs.

## How to Validate Cache Is Working

**Always use `--progress=plain`** — without it, Docker hides whether layers were cached:

```bash
BUILDKIT_PROGRESS=plain docker compose build
```

Look for `CACHED` on `RUN` steps. If you see `exporting cache` or `pushing cache to registry`, `cache_to` is being honored.

**Minimal end-to-end test** (simulates two machines on one box):

```bash
# 1. Build and push (CI-like)
docker buildx build --tag myregistry/myapp:ci --push .

# 2. Destroy local state
docker image rm myapp:ci myregistry/myapp:ci

# 3. Pull the pushed image
docker pull myregistry/myapp:ci

# 4. Rebuild using it as cache — pip install should show CACHED
docker buildx build \
  --progress=plain \
  --cache-from=myregistry/myapp:ci \
  --tag myapp:dev \
  --load \
  .
```

**Local registry** (no credentials, no network) for rapid iteration:

```bash
docker run --detach --publish 5000:5000 --name registry registry:2
docker tag myapp:ci localhost:5000/myapp:ci
docker push localhost:5000/myapp:ci
```

**Docker contexts** simulate two fully isolated machines (separate image stores and caches) on one host:

```bash
docker context create ci-machine
docker context create dev-machine

docker context use ci-machine
docker buildx build --tag myapp:ci .

docker context use dev-machine
docker buildx build --cache-from=myregistry/myapp:ci --tag myapp:dev .
```

**Force a cache miss** when you need a clean baseline:

```bash
docker buildx build --no-cache .
```

**Embed a timestamp** in the Dockerfile to make cache invalidation visible (remove after testing):

```dockerfile
RUN echo "DEPS LAYER REBUILT $(date)" && pip install --no-cache-dir -r requirements.txt
```

If the timestamp prints, cache was invalidated. If it's absent from output, the layer was cached.

## Nightly Cache Warm Across Projects

The goal: pull the latest CI image for each project every Monday morning so `docker compose build` is instant during the week.

### Project Registration

Each project already has a per-repo activation script (e.g. `activate_project_x.ps1` → `cd ~/projects/x`). A warm script can use the same convention: a list of project roots + their registry image refs.

**`~/bin/docker-warm.sh`** (minimal, extend per project):

```bash
#!/usr/bin/env bash
set -euo pipefail

declare -A PROJECTS=(
  ["$HOME/projects/x"]="artifactory.example.com/myteam/flask-app-server:buildcache"
  ["$HOME/projects/other-service"]="artifactory.example.com/myteam/other-service:buildcache"
)

for dir in "${!PROJECTS[@]}"; do
  image="${PROJECTS[$dir]}"
  echo "==> Warming $dir from $image"
  docker pull "$image" || echo "WARN: pull failed for $image, skipping"
  (cd "$dir" && docker compose build) || echo "WARN: build failed in $dir"
done
```

### Scheduling on macOS (`launchd`)
- [ ] use [[pitchfork]] instead

`~/Library/LaunchAgents/com.darthwalsh.docker-warm.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.darthwalsh.docker-warm</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>/Users/walshca/bin/docker-warm.sh</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Weekday</key>
        <integer>1</integer>
        <key>Hour</key>
        <integer>7</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
    <key>StandardOutPath</key>
    <string>/tmp/docker-warm.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/docker-warm.err</string>
</dict>
</plist>
```

```bash
launchctl load ~/Library/LaunchAgents/com.darthwalsh.docker-warm.plist
```

`Weekday` integer: 0=Sunday, 1=Monday … 7=Sunday.

### Alternatives

- **[Watchtower](https://github.com/containrrr/watchtower)**: runs as a container, polls the registry, auto-pulls and restarts running containers. Good if containers stay running; overkill for dev machines where nothing is running overnight.
- **[dockcheck](https://github.com/mag37/dockcheck)**: CLI script that checks for image updates selectively and can prune old images. Works well as a cron/launchd target if you don't want the warm script above.

## V2: Also Warm the Host venv

Activation is cheap; installation is deliberate. The same warm script can also refresh host-side venvs when `requirements.txt` changes:

**Mental model**: hash `requirements.txt` → if hash changed since last warm, run `pip install -r requirements.txt` and update the stored hash.

```bash
HASH_FILE="$dir/.venv/.last-requirements-hash"
CURRENT_HASH=$(sha256sum "$dir/requirements.txt" | awk '{print $1}')
STORED_HASH=$(cat "$HASH_FILE" 2>/dev/null || echo "")

if [[ "$CURRENT_HASH" != "$STORED_HASH" ]]; then
  echo "==> requirements.txt changed, reinstalling..."
  (cd "$dir" && pip install -r requirements.txt)
  echo "$CURRENT_HASH" > "$HASH_FILE"
fi
```

Nightly installs with unpinned requirements silently change the environment — only do this if `requirements.txt` is pinned or you want controlled drift.
