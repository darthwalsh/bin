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
cron = { schedule = "0 */5 * * * *", retrigger = "finish" }
# retrigger = "finish" skips the next trigger if the previous run hasn't completed
# cron schedule is 6 fields: second minute hour day month weekday
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
