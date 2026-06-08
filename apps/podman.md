## Install
https://podman.io/docs/installation
```command
brew install podman
podman machine init    # once
podman machine start
podman info
```

Homebrew bundles the macOS VM helpers (`gvproxy`, `vfkit`) under.
Do **not** install via [[mise]]: fails looking for `gvproxy`.

### Autostart
Do you want auto-start? The VM uses ~1 GB RAM sitting idle.
Could use [[launchd]] or [[pitchfork]], or add to your shell profile: `podman machine start --no-info 2>/dev/null &`

## List Tags
```
podman search --list-tags docker.io/alpine --limit 10
```
