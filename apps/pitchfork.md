- [ ] https://pitchfork.jdx.dev/guides/web-ui.html
I have [linked dotfile](../dotfiles/.pitchfork.toml).
## Install
https://pitchfork.jdx.dev/quickstart.html has great integration with [[mise]].

```bash
mise use -g pitchfork
pitchfork supervisor start
pitchfork boot enable   # https://pitchfork.jdx.dev/guides/boot-start.html#how-it-works

# Verify
pitchfork supervisor status
pitchfork boot status
```

## Adding a daemon
Daemons in `~/.config/pitchfork/config.toml` use the `global` namespace.

```toml
namespace = "global"

[daemons.my-job]
run = "pwsh -NoProfile -File /path/to/script.ps1"
mise = true   # wraps with `mise x --` so mise-managed tools are on PATH
dir = "/path/to/working/dir"

boot_start = true # https://pitchfork.en.dev/guides/boot-start#configure-boot-daemons

# retrigger = "finish" skips the next trigger if the previous run hasn't completed
# cron schedule is 6 fields: second minute hour day month weekday
cron = { schedule = "0 */5 * * * *", retrigger = "finish" }
```

After editing the config, reload with:
```bash
pitchfork supervisor stop && pitchfork supervisor start
```

See [[crontab]].

## Useful commands
```bash
pitchfork list                     # all daemons and their status
pitchfork logs my-job              # recent logs
pitchfork logs my-job --tail       # follow logs
pitchfork logs my-job --clear      # delete all logs
pitchfork status my-job
pitchfork start my-job             # start (or trigger cron job immediately)
pitchfork stop my-job
pitchfork restart my-job
pitchfork tui                      # interactive dashboard
```

For daemons in global config, short names resolve without needing `global/my-job`.

## launchd / Task Scheduler vs pitchfork
Pitchfork replaces platform-native schedulers (macOS `launchd` plist, Windows [[TaskScheduler]] XML/UI, Linux [[systemd]] timers) with TOML config and a CLI. Under the hood it registers with native boot mechanisms (apparently Registry on Windows).

>[!WARNING] Won't wake from sleep
One limitation is no deep OS event triggers, e.g. `launchd` has `StartCalendarInterval` which wakes macOS from sleep to run a job.

If wake-from-sleep is required, one option is a minimal launchd plist that calls `pitchfork start <daemon>` using `StartCalendarInterval`, keeping pitchfork for log management and retries.

## Debugging: all daemons stuck as "available" after mise upgrade
**Symptom:** `pitchfork list` shows all daemons as `available`, no logs since weeks ago. `status.txt` updated only from a manual script run.

**Diagnose:**
```bash
launchctl list pitchfork   # non-zero LastExitStatus = boot agent failed
ls ~/.local/share/mise/installs/pitchfork/   # 2.5.0 missing, only 2.10.0
```

**Root cause:** `pitchfork boot enable` writes the resolved binary path into the launchd plist ([`src/env.rs`](https://github.com/endevco/pitchfork/blob/main/src/env.rs): `current_exe().canonicalize()` resolves through the mise shim to the versioned path). The `mise-upgrade` daemon upgraded pitchfork `2.5.0 → 2.10.0` (~May 14), deleting the old binary. On next reboot, launchd tried to exec the stale `2.5.0` path → exit 78 (binary not found). Supervisor was manually restarted without `--boot`, so daemons never auto-started.

### Workaround
**Fix:** Patch the plist to use the shim path, which is version-agnostic:
```bash
# Edit ~/Library/LaunchAgents/pitchfork.plist
# Change ProgramArguments[0] from:
#   /Users/walshca/.local/share/mise/installs/pitchfork/2.5.0/pitchfork
# to:
#   /Users/walshca/.local/share/mise/shims/pitchfork

launchctl unload ~/Library/LaunchAgents/pitchfork.plist
launchctl load ~/Library/LaunchAgents/pitchfork.plist
pitchfork start gh-pr-status mise-upgrade renovate-approver
```

Simple workaround sets up failure on next upgrade: re-running `pitchfork boot enable` justhardcodes the current version path again.

### Bug report draft
#ai-slop
- [ ] TODO nut sure about symlink below: pitchfork → mise so which was the missing binary?
For: endevco/pitchfork repo

**Title:** `pitchfork boot enable` hardcodes versioned binary path in launchd plist, breaks boot after `mise upgrade`

**Steps to reproduce:**
1. Install pitchfork via mise: `mise use -g pitchfork`
2. `pitchfork boot enable` — creates `~/Library/LaunchAgents/pitchfork.plist` with `ProgramArguments[0]` pointing to e.g. `~/.local/share/mise/installs/pitchfork/2.5.0/pitchfork`
3. `mise upgrade pitchfork` — installs 2.10.0, removes 2.5.0
4. Reboot. Launchd fails to start the supervisor: `launchctl list pitchfork` shows
    `LastExitStatus = 19968` (exit 78, binary missing). All daemons stay `available` and never run.

**Expected:** boot start survives a mise upgrade without manual intervention.

**Root cause:** `env::PITCHFORK_BIN` calls `current_exe().canonicalize()`, which follows the mise shim symlink (`~/.local/share/mise/shims/pitchfork → /opt/homebrew/bin/mise`) all the way to the versioned binary, so the resolved path is baked into the plist.

**Workaround:** manually edit the plist to use the shim path (`~/.local/share/mise/shims/pitchfork`), which mise resolves to the active version at runtime.

**Suggested fix:** in `boot_manager.rs`, before calling `build_launcher`, check whether a mise shim exists for the pitchfork binary (e.g. `~/.local/share/mise/shims/pitchfork`) and prefer that path over `PITCHFORK_BIN`. Alternatively, expose a `--bin-path` flag on `pitchfork boot enable`
