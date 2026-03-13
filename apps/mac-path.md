## Shell PATH uses path_helper
Only for **login** shells[^1], `path_helper` is called from `/etc/profile` — **only** for login shells.
```bash
if [ -x /usr/libexec/path_helper ]; then
        eval `/usr/libexec/path_helper -s`
fi
```
(Ditto `/etc/zprofile` for zsh.)

`/usr/libexec/path_helper` reads:
- `/etc/paths` — system-wide paths (includes `/opt/homebrew/bin` on Apple Silicon Macs with Homebrew installed)
- `/etc/paths.d/*` — drop-in files added by installers (e.g. `dotnet`)
And prints the command for eval: `PATH="/opt/homebrew/bin:..."; export PATH;`

Then, user dotfiles (`~/.zprofile`, `~/.zshrc`, etc.) might set more `PATH` values.

## GUI inherits launchd PATH
When macOS boots and you log in via the GUI, `launchd` sets the initial PATH for all user processes. This may not include everything in `/etc/paths`.

GUI apps (Cursor, VSCode, etc.) spawn child processes — MCP servers, language servers, build tools — that inherit this launchd PATH. If `/opt/homebrew/bin` isn't in it, commands like `node`, `npx`, `docker` come up "not found" even though they work fine in a terminal.

I asked about how to fix this on [Apple Stack Exchange](https://apple.stackexchange.com/questions/429680/how-to-set-path-and-other-env-vars-for-apps-with-reopen-windows-when-logging-ba)

## Best Solution: Sync launchd PATH from shell profile
> [!WARNING] everything from here below is #ai-slop  and needs to be tested


Add this **at the end** of `~/.zprofile` (after all other PATH additions), so launchd always reflects the fully-built shell PATH:

```zsh
# At the very end of ~/.zprofile:
launchctl setenv PATH "$PATH"
```

Every time a login shell opens (new iTerm tab, Terminal.app), it rebuilds PATH normally, then syncs it into launchd. Any GUI app opened or restarted after that inherits the full PATH.

**Limitation**: `launchctl setenv` does **not** survive reboot — it only sets the value for the current login session. Fresh reboot + open Cursor before any terminal → Cursor still gets the minimal launchd PATH. Once you open any terminal tab (triggering zprofile), launchd gets updated and Cursor will have the full PATH on next restart.

---

## Observed Facts (empirical)
> [!WARNING] everything from here below is #ai-slop  and needs to be tested

- After reboot, MCP `echo $PATH >&2` outputs tiny path
    - After claude restart or logout/login, it outputs 30+ paths including some PATH entries **only** added by the PowerShell profile 
    - Cursor was almost certainly launched from a PowerShell terminal and **inherited its env**, not launchd's
- `launchctl setenv PATH "/SENTINEL_TEST"` → sentinel did **not** appear in `osascript` output — confirming osascript inherits the caller's env, not launchd's

### Tools that do NOT work to read another process's env on macOS
> [!WARNING] everything from here below is #ai-slop  and needs to be tested

| Tool | Why it fails |
|---|---|
| `osascript -e 'do shell script "echo $PATH"'` | Inherits caller's shell env, not launchd |
| `ps eww -p <pid>` on orphaned process | Works, but orphaned processes (reparented to launchd after parent exits) return empty KERN_PROCARGS2 — need a live, non-orphaned process |
| `/proc/<pid>/environ` | Doesn't exist — Linux only |
| `psutil.Process.environ()` | Returns `{}` for Cursor Helper and child processes |
| `sysctl KERN_PROCARGS2` via ctypes (even with sudo) | Also returns empty for these processes |

The psutil/sysctl failures on the MCP `sleep` processes were likely because those processes had been **orphaned** (their parent `/bin/sh` exited, reparenting them to launchd). Once orphaned, `KERN_PROCARGS2` returns empty. `ps eww` on a live, non-orphaned process (e.g. PID of pwsh inside Cursor's terminal) works fine and shows the full environment.

### Reliable tools
> [!WARNING] everything from here below is #ai-slop  and needs to be tested


- `launchctl getenv PATH` — reads launchd user env database directly, not any shell
- `ps eww -p <pid>` — shows full env appended to command line (redirect to file for long output; only works on non-orphaned processes)
- MCP `echo $PATH >&2` — ground truth for what Cursor actually passes to spawned processes

---

## Testing Procedure

Use a sentinel value to confirm launchd PATH is actually being picked up, without relying on a terminal (which rebuilds PATH via login shell and would mask the test):

```zsh
# 1. Read what launchd currently has
launchctl getenv PATH

# 2. Inject a sentinel (prepend something obviously fake)
launchctl setenv PATH "/SENTINEL_TEST:$(launchctl getenv PATH)"

# 3. Confirm it's set in launchd (not just your shell)
launchctl getenv PATH | grep SENTINEL   # should match

# 4. Open a fresh Cursor window (launched from Dock, not terminal).
#    Add path-debug MCP, check its stderr output for SENTINEL.
#    Do NOT test via osascript — it inherits caller env, not launchd.

# 5. Clean up
launchctl setenv PATH "$(launchctl getenv PATH | sed 's|/SENTINEL_TEST:||')"
```

> **Why not `osascript`?** Confirmed broken: `launchctl setenv PATH "/SENTINEL_TEST"` was set, osascript did not show it. Osascript inherits the calling shell's PATH.

> **Why not Terminal.app?** It starts a login shell → runs `~/.zprofile` → rebuilds PATH from scratch, losing the sentinel.

> **`launchctl getenv PATH`** is the ground truth for what GUI apps will see (reads launchd directly).

### Cursor MCP path probe
```json
"path-debug": {
    "command": "/bin/sh",
    "args": ["-c", "echo $PATH >&2; sleep 500"]
}
```
Keep `sleep 500` so the process stays alive for `pstree`/`ps` inspection.
Baseline output (Cursor launched from Dock, no terminal open): `[error] /usr/bin:/bin:/usr/sbin:/sbin`
Observed output (Cursor launched from PowerShell terminal): 30+ paths including PowerShell-profile additions.

### Next: test the actual fix
1. Add `launchctl setenv PATH "$PATH"` to end of `~/.zprofile`
2. Open a new iTerm login shell tab (triggers zprofile, syncs PATH to launchd)
3. `launchctl getenv PATH` — confirm it now has homebrew paths
4. Restart Cursor **from Dock** (not terminal)
5. Check MCP path-debug output — should have homebrew paths
6. Repeat after full logout/login to confirm it survives reboot

---

## Other Solutions
> [!WARNING] everything from here below is #ai-slop  and needs to be tested


**Absolute paths in MCP/tool configs** — no launchd dependency at all:
```json
{ "command": "/opt/homebrew/bin/node" }
```

**`launchctl config user path`** — survives reboots, but requires full logout/login to take effect:
```zsh
# Read (requires sudo; file may not exist until first write):
sudo /usr/libexec/PlistBuddy -c "Print :PathVariables:PATH" \
  /private/var/db/com.apple.xpc.launchd/config/user.plist

# Set:
sudo launchctl config user path \
  "/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
```

**Wrap MCP command in a login shell** — per-entry fix in config:
```json
{ "command": "/bin/zsh", "args": ["-lc", "exec node /path/to/server.js"] }
```

## Dock launch vs terminal launch

Cursor launched from **Dock** (or Spotlight, or `open -a Cursor`) is a child of launchd — it gets the launchd env, which has the minimal PATH (`/usr/bin:/bin:/usr/sbin:/sbin`).

Cursor launched from a **terminal** (e.g. `cursor .` from PowerShell) inherits the terminal's full env, including all profile-added paths. Evidence: `ps eww` on a Cursor-internal pwsh showed `__CFBundleIdentifier=com.todesktop.230313mzl4w4u92` and `TERM_PROGRAM=vscode` alongside 30+ PATH entries that only exist in the PowerShell profile. This explains why "it works sometimes" — it depends on how Cursor was started.

To test launchd inheritance specifically, always launch Cursor from the Dock (or `open -a Cursor`), never from a terminal.

## The Reboot Problem

After a fresh reboot, apps opened from the Dock before a terminal session has run may have an even narrower PATH — the launchd PATH is set at login, and whether it picks up `path_helper`'s output depends on macOS version. This is the "works after I open a terminal first" class of bug. Absolute paths in configs sidestep this entirely.

[^1]: In iTerm, the default profile is a login shell, but creating a new profile to run the zsh command will not be login
