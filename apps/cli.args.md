#ai-slop

## Unix flag conventions: bundling vs value-flags

Two coexisting styles that come from different parser conventions:

- **Bundled short flags** (`-lad`, `-rf`): each letter is a separate boolean switch, combined after one dash
- **Flag with attached value** (`-n10`, `-L10`): a single flag that consumes the characters immediately after it as its value
- **Flag with separate value** (`-n 10`): same flag, value as next token

These are *not* incompatible — they coexist in the same tool if the parser is written to distinguish "this flag expects a value" vs "this flag is boolean." The ambiguity only surfaces when you mix them (`-ab10`: does `b` take `10`, or is it boolean and `10` is a positional?). Each tool resolves this per its own parser configuration.

## Python CLI libraries

| Library    | `-abc` | `-n 10` | `-n10` | Philosophy                       |
| ---------- | ------ | ------- | ------ | -------------------------------- |
| `argparse` | ✅      | ✅       | ⚠️     | POSIX-leaning, pragmatic, stdlib |
| `click`    | ✅      | ✅       | ❌      | Opinionated, UX-first            |
| `typer`    | ✅      | ✅       | ❌      | Typed, modern (built on Click)   |
| `docopt`   | ✅      | ✅       | ✅      | Spec-driven, Unix-style          |

`click`/`typer` deliberately restrict attached-value short flags for clarity. `argparse` supports `-n10` but doesn't advertise it. `docopt` follows whatever the usage string specifies.

For Unix composition: `argparse` or `docopt`. For clarity and safety: `click`/`typer`.

## PowerShell parameter basics

PowerShell does not follow Unix flag semantics. Parameters are named, not positional flags:

```powershell
Remove-Item -Recurse -Force   # not rm -rf
Get-ChildItem -Recurse        # not ls -R
```

Key differences from Unix:
- No short-flag bundling (`-rf` ❌)
- Partial parameter names work: `-Rec` resolves to `-Recurse`
- `--` is end-of-parameters marker only, not a long-option prefix
- Values are space-separated: `-Depth 10`, not `-Depth10`

### Switches (boolean flags)

`[switch]` parameters are a special type — they're boolean by presence, but have a subtle quirk: you can explicitly pass `$false` to override a default:

```powershell
param([switch]$Verbose)

# Calling:
./script.ps1 -Verbose          # $Verbose = $true
./script.ps1 -Verbose:$false   # $Verbose = $false (unusual but valid)
./script.ps1                   # $Verbose = $false
```

The `:$false` syntax is non-obvious and rarely needed, but exists for cases where a caller wants to explicitly suppress a switch that a wrapper might set.

### Mandatory parameters and prompting

Parameters marked `[Parameter(Mandatory=$true)]` cause PowerShell to interactively prompt if not supplied:

```powershell
param(
    [Parameter(Mandatory=$true)]
    [string] $Name
)
```

```
cmdlet script.ps1 at command pipeline position 1
Supply values for the following parameters:
Name: _
```

This is useful for interactive scripts but can be surprising in automation — a missing required param will hang waiting for input rather than failing fast. Use `$ErrorActionPreference = "Stop"` and validate early for scripts that run in CI.

### Static discoverability via comment-based help

PowerShell's `param()` block + [comment-based help](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_comment_based_help) makes scripts statically introspectable via `Get-Help` and `Get-Command`. This enables tools like [[funcmd.ps1]] to extract parameter docs at runtime:

```powershell
<#
.SYNOPSIS
Short description shown in Get-Help
.PARAMETER Name
Description of the Name parameter
#>
param(
    [Parameter(Mandatory=$true)]
    [string] $Name
)
```

`Get-Help ./script.ps1 -Full` returns structured parameter metadata including types, defaults, and whether mandatory. This is what makes tab completion, `funcmd.ps1`-style doc generation, and IDE tooling work without any extra annotation framework.

### Short-flag aliases

You can approximate Unix short flags with `[Alias()]`, but bundling still doesn't work:

```powershell
param(
    [Alias('r')] [switch] $Recurse,
    [Alias('f')] [switch] $Force
)
# ./tool.ps1 -r -f   ✅
# ./tool.ps1 -rf     ❌ (no bundling)
```

## Trogon: auto-generate a TUI from a CLI
#ai-slop

[Trogon](https://github.com/Textualize/trogon) introspects a Python CLI's argument graph and renders a form-based TUI for it — no extra code needed if the CLI is built with Click (Typer works too via Click's internals).

```bash
pip install trogon
trogon my-cli-command   # launches TUI for that command
```

Or add it inline to an existing Click app:

```python
import click
from trogon import tui

@tui()
@click.group()
def cli(): ...
```

Why it works: Click/Typer store the full parameter graph as structured data at runtime. Trogon reads that graph directly — it doesn't parse `--help` text. This is why there's no equivalent for arbitrary native commands (no structured graph to read).

- Works as a standalone launcher or embedded in the CLI itself
- No shell integration for "pause mid-command → switch to TUI → resume" — that workflow requires a separate shell-level key binding (see [[pwsh.completions]] or [[cli.args]] PSReadLine section)

## PSReadLine: interactive line editing hooks

PSReadLine is PowerShell's interactive line editor (analogous to GNU Readline in bash, ZLE in zsh). It handles keybindings, history search, and predictive IntelliSense.

Extension points:
- **Key handlers** (`Set-PSReadLineKeyHandler`): bind a key chord to a scriptblock that can read/rewrite the current buffer
- **Predictor plugins**: modules that hook into the suggestion subsystem (beyond history)
- **Options** (`Set-PSReadLineOption`): edit mode, history behavior, prediction view style

Notable tools using PSReadLine hooks:
- [PSFzf](https://github.com/kelleyma49/PSFzf): binds `Ctrl+T` (path picker), `Ctrl+R` (fuzzy history), and overrides Tab completion
- [CompletionPredictor](https://github.com/PowerShell/CompletionPredictor): reference predictor plugin example from Microsoft
- Oh My Posh: coordinates with PSReadLine for transient prompt behavior

### Push/pop buffer stack (zsh `push-line` equivalent)

Zsh has a built-in `push-line` ZLE widget: stash the in-progress buffer, run a helper command, buffer auto-restores. PSReadLine has no built-in equivalent, but the buffer APIs make it implementable:

```powershell
# Add to $PROFILE
if (-not $global:__PSRL_LineStack) {
    $global:__PSRL_LineStack = New-Object 'System.Collections.Generic.Stack[object]'
}

Set-PSReadLineKeyHandler -Chord 'Ctrl+Alt+p' -BriefDescription 'Push line' -ScriptBlock {
    $line = $null; $cursor = 0
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    $global:__PSRL_LineStack.Push([pscustomobject]@{ Line = $line; Cursor = $cursor })
    [Microsoft.PowerShell.PSConsoleReadLine]::Replace(0, $line.Length, '')
    [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition(0)
}

Set-PSReadLineKeyHandler -Chord 'Ctrl+Alt+o' -BriefDescription 'Pop line' -ScriptBlock {
    if ($global:__PSRL_LineStack.Count -le 0) { return }
    $saved = $global:__PSRL_LineStack.Pop()
    $cur = $null; $ignored = 0
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$cur, [ref]$ignored)
    [Microsoft.PowerShell.PSConsoleReadLine]::Replace(0, $cur.Length, '')
    if ($saved.Line) {
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert($saved.Line)
        [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition([Math]::Min([int]$saved.Cursor, $saved.Line.Length))
    }
}
```

Workflow: type a partial command → `Ctrl+Alt+P` to stash → run helper commands → `Ctrl+Alt+O` to restore.

Gotcha: on iTerm2/macOS, `Ctrl+Alt+*` chords require iTerm's Option key set to "Meta" (Preferences → Profiles → Keys). If not, bind to function keys (`-Chord F6`) instead.

Built-in near-equivalent without custom code: `Ctrl+R` (history search) → `Ctrl+G` (abort search, keeps your original buffer intact).

### #app-idea Unix combined-flag rewriter

PSReadLine's Enter-key handler intercepts the raw buffer string before PowerShell parses it. This could rewrite Unix-style combined flags to their PowerShell equivalents before execution.

Motivation: `rm -rf` fails on Windows (`-rf` is not a valid parameter); the correct form is `Remove-Item -Recurse -Force`. A PSReadLine Enter handler could detect `-rf` (or similar bundled flags) on known commands and expand them to separate named params before the line is submitted.

Rough shape:
1. Intercept buffer on Enter
2. `Get-Command` to resolve the first token
3. If it's a known cmdlet/function with a flag map, rewrite bundled short flags to full named params
4. `AcceptLine` with the rewritten buffer

Limitation: no global engine-level pre-parse hook exists for non-interactive use (scripts, CI). This only works in interactive sessions that load PSReadLine.

## Zsh / bash line-buffer tools (cross-shell reference)

| Technique                          | zsh          | bash (no plugins) | PowerShell (PSReadLine)                  |
| ---------------------------------- | ------------ | ----------------- | ---------------------------------------- |
| Push buffer to stack               | `push-line` (ZLE built-in) | No (GNU Readline has partial analog via `~/.inputrc`) | No built-in; implementable via key handler |
| Edit buffer in `$EDITOR`           | `edit-command-line` (`Ctrl+X Ctrl+E`) | Yes (`edit-and-execute-command`) | Yes (`ViEditVisually`, `Ctrl+X Ctrl+E` in Emacs mode) |
| Reverse history search             | `Ctrl+R`     | Yes (Readline)    | Yes (PSReadLine)                         |
| Yank last arg                      | `Alt+.`      | Yes (Readline)    | Yes (`YankLastArg`, `Alt+.`)             |
| History expansion (`!!`, `!$`)     | Yes          | Yes               | No                                       |
| `fc` (edit history entry in editor) | Yes         | Yes (POSIX)       | No (`Get-History`/`Invoke-History` instead) |
| Fuzzy history (fzf/atuin)          | With plugin  | With plugin       | With plugin (PSFzf)                      |
| Job control (`Ctrl+Z`, `fg`)       | Yes          | Yes               | No (PowerShell jobs model instead)       |
