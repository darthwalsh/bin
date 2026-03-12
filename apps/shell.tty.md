#ai-slop
# TTY and PTY: how programs detect interactivity

## TTY vs PTY
A **TTY** (teletypewriter) is a kernel device representing a terminal. Historically it was a physical serial line; today it's almost always a **PTY** (pseudo-terminal).

A **PTY** is a kernel-managed pair of file descriptors:
- **Controller side** (`/dev/ptmx`): held by the terminal emulator (iTerm2, GNOME Terminal, etc.), which reads/writes raw bytes and renders them
- **Subordinate side** (`/dev/pts/N`): what the shell and child processes see as their `stdin`/`stdout`/`stderr`

From a process's point of view, the subordinate PTY looks identical to a real TTY. That's by design — programs can't tell if they're talking to a human in a terminal emulator or to another program holding the controller side.

## Detecting interactivity: `isatty` and friends
The kernel exposes one key question: *is this fd connected to a terminal device?*

In [[C]] you `#include <unistd.h>` then:

| Call | What it tells you |
|------|-------------------|
| `isatty(fd)` | Boolean: is this fd a terminal? |
| `tcgetattr(fd, &termios)` | Get terminal attributes (line discipline, raw vs cooked mode) |
| `ttyname(fd)` | Returns e.g. `/dev/pts/3` — the device name |
| `tcgetpgrp(fd)` | Returns the foreground process group of the terminal — useful to check if a process is in the foreground |

In [[bash]] `-t N` is the bash wrapper for `isatty(N)`, `-p` tests for a named pipe (FIFO), `-f` for a regular file. 
```bash
if [ -t 0 ]; then
  echo "stdin: interactive terminal"
elif [ -p /dev/stdin ]; then
  echo "stdin: pipe from another process"
elif [ -f /dev/stdin ]; then
  echo "stdin: redirected from a file"
else
  echo "stdin: closed or unknown"
fi
```

**What you cannot distinguish:**
- A real human terminal vs. a PTY (ssh session, `expect`, `screen`, `tmux`) — `isatty` returns true for both
- A pipe with no data yet vs. a terminal where the user hasn't typed — both block on `read`
- Pipe vs. file once both are actively streaming data

## When stdout is not interactive: auto-color and formatting
Programs key output formatting on whether **stdout** is a pipe (means another program is reading).

The standard decision tree most tools follow:
```
if isatty(stdout)
  and TERM != "dumb"
  and NO_COLOR is not set
then
  enable color, pagination, decorations
else
  plain text, no ANSI escapes
```

Common programs that change with e.g. `ls | cat` (but often have e.g. `--color` flags)

| Program       | TTY stdout                           | Piped stdout                 |
| ------------- | ------------------------------------ | ---------------------------- |
| `ls`          | multi-column, colorized by file type | one entry per line, no color |
| `rg` / `grep` | colorized matches, filename headings | plain `filename:match`       |
| `git diff`    | colorized, paged through `less`      | plain unified diff           |
| `git log`     | paged, colorized graph               | plain text                   |
| `jq`          | colorized JSON                       | plain JSON                   |

**Relevant environment variables:**

| Variable | Effect |
|----------|--------|
| `TERM=dumb` | Signals a terminal with no capability; many tools disable color |
| `NO_COLOR=1` | [Standard](https://no-color.org/) respected by most modern tools: suppress all ANSI color |
| `COLORTERM=truecolor` | Tells color-aware tools to use 24-bit RGB |
| `FORCE_COLOR=1` | Non-standard but common (Node.js ecosystem): force color even when not a tty |


## When stdin is not interactive: prompts and blocking behavior

When `isatty(stdin)` is false, a program knows no human is at the keyboard. This changes:

**Prompts are suppressed or fail:**
- `git` credential helper — if stdin is not a tty, git cannot prompt for a username/password; it fails with an auth error rather than blocking forever on a prompt nobody will answer
- `ssh` — won't prompt for a passphrase if stdin is not a tty; use `-o BatchMode=yes` to make this explicit
- `sudo` — by default requires a tty for password input; `sudo -S` reads password from stdin instead, `sudo -n` fails instead of prompting
- `gpg` — similarly won't prompt for a PIN or passphrase when non-interactive; use `--batch --passphrase-fd 0`
- Python's `input()` / bash's `read` — block forever waiting for a prompt nobody answers, or fail immediately if stdin is closed

**Shell interactive mode:**
Bash declares itself interactive if stdin is a tty and the `-i` flag is set (or implied). Running `bash < script.sh` is non-interactive even though a human launched it — it loads `~/.bashrc` differently and disables job control.

**Buffering changes (libc):**
See also [[linux.io-write]] — when stdout is a tty, `FILE*` stdio defaults to *line-buffered* (flush on `\n`). When stdout is a pipe or file, it switches to *fully buffered* (~8 KB block). This is why `printf "updating...\r"` in a pipeline seems to disappear: the buffer never flushes mid-line.

Fix: `stdbuf -oL your-command` forces line-buffered stdout on an arbitrary program without recompiling.

## PTY consumers: docker, ssh, tmux, screen
These programs all need a PTY because the child process they run would otherwise see a non-interactive stdin/stdout and behave differently (suppress prompts, strip color, disable job control).

**Programs that allocate a PTY to "fool" child processes:**

| Program                     | What it does                                                                                                               |
| --------------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| `ssh`                       | Allocates a PTY on the remote host (pass `-t` to force; `-T` to disable); the remote shell sees a tty                      |
| `docker -it`                | `-i`: keep stdin open (pipe), but still no tty<br> `-t`: allocate a PTY, but stdin not attached → broken                   |
| `tmux` / `screen`           | Each pane/window gets its own PTY; programs inside see a real tty even though tmux itself may be running non-interactively |
| `script`                    | Records a terminal session by wrapping the shell in a PTY and logging all output                                           |
| `expect` / `pexpect`        | Drives another program through a PTY so it produces interactive output and accepts scripted input                          |
| `unbuffer` (expect package) | Wraps a command in a PTY to force it to flush output as if to a terminal — useful to fix buffering in pipelines            |
| `faketty` (util-linux)      | Minimal tool: run a command with a fake tty on stdout                                                                      |
| `strace -e trace=ioctl`     | Shows tty-related `ioctl` calls — useful for debugging what a program thinks its terminal is                               |

**The PTY "trick" in detail:**
A PTY fools `isatty()` because the subordinate fd is a genuine terminal device (`ttyname()` returns `/dev/pts/N`). The kernel's line discipline (input editing, signal generation on `Ctrl-C`) applies to the subordinate just as it does to a hardware terminal. The controller side sees everything typed and everything written.

This is why tmux can forward `Ctrl-C` correctly into a pane, why ssh can pass terminal resize events (`SIGWINCH`), and why `expect` can detect a password prompt and respond to it — they're all operating through the PTY controller.
