# XDG Base Directory Specification

The [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html) standardizes where Unix apps store config, data, cache, and runtime files — instead of scattering dotfiles across `$HOME`. See the [Arch Linux practical guide](https://wiki.archlinux.org/title/XDG_Base_Directory) for real-world app compliance.

| Directory       | Env var            | Default            | Purpose                     |
|----------------|--------------------|--------------------|------------------------------|
| Config          | `XDG_CONFIG_HOME`  | `~/.config`        | User settings                |
| Data            | `XDG_DATA_HOME`    | `~/.local/share`   | Persistent app data          |
| Cache           | `XDG_CACHE_HOME`   | `~/.cache`         | Regenerable/temp data        |
| Runtime         | `XDG_RUNTIME_DIR`  | (set by OS/login)  | Sockets, pipes, short-lived  |

XDG is Linux-only — macOS and Windows have their own conventions. Libraries like `platformdirs` abstract over all three:

| OS      | Resolved path                                   | Env var           |
|---------|------------------------------------------------|-------------------|
| Linux   | `~/.local/share/my-tool`                       | `$XDG_DATA_HOME`  |
| macOS   | `~/Library/Application Support/my-tool`        | —                 |
| Windows | `%LOCALAPPDATA%\my-tool`                       | `LOCALAPPDATA`    |

## Suggested Libraries (Python)

Use a library rather than hardcoding `~/.local/share` — that path is Linux-specific.

- **[`platformdirs`](https://pypi.org/project/platformdirs/)** — MIT license. Recommended. Successor to [`appdirs`](https://pypi.org/project/appdirs/), actively maintained. Handles Linux (XDG), macOS, and Windows correctly.
- There are also **[`xdg`](https://pypi.org/project/xdg/)** and **[`xdg-base-dirs`](https://pypi.org/project/xdg-base-dirs/)** libraries, but they don't have the same platform support.

## Zero-dep fallback

```python
import os
import sys
from pathlib import Path

def data_dir(app_name: str) -> Path:
    if sys.platform == "win32":
        base = os.environ.get("LOCALAPPDATA")
        return (Path(base) if base else Path.home() / "AppData" / "Local") / app_name
    elif sys.platform == "darwin":
        return Path.home() / "Library" / "Application Support" / app_name
    else:
        xdg = os.environ.get("XDG_DATA_HOME")
        base = Path(xdg) if xdg else Path.home() / ".local" / "share"
        return base / app_name

print(data_dir("my-tool"))  # /Users/walshca/Library/Application Support/my-tool
```

This is essentially what `platformdirs` does internally — just delegate to it unless you have a strict zero-dep constraint.
