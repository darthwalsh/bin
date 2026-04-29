---
aliases:
  - pwsh profile timing
  - powershell startup slow
---
#ai-slop 
## Profile startup is slow: use `Set-PSDebug` to rank culprits

`Set-PSDebug -Trace 1` emits a DEBUG line per executed statement. Capture those with wall-clock timestamps, then diff consecutive lines to get per-statement cost — no manual `Log-Step` annotations needed. Works well when there are dozens of suspects.

> **Gotcha**: DEBUG output does [not redirect with `*>&1`](https://stackoverflow.com/questions/36319502/log-output-of-powershell-psdebug-trace-to-a-file). Spawn a child `pwsh` process so DEBUG goes to stdout:
> ```powershell
> pwsh -c 'Set-PSDebug -Trace 1; . $PROFILE' *>&1 | % { "$(Get-Date -Format o) $_" } > $env:TEMP\ps-profile-psdebug.log
> ```
> Running it inside the current session silently drops the trace lines.

### Capture: instrument `$PROFILE`

At the **very top**:

```powershell
$global:PsDebugLog = "$env:TEMP\ps-profile-psdebug.log"
Remove-Item $PsDebugLog -ErrorAction Ignore

$sw = [Diagnostics.Stopwatch]::StartNew()
Set-PSDebug -Trace 1
```

At the **very bottom**:

```powershell
Set-PSDebug -Off
$sw.Stop()
```

Open a new shell once — the log is now written.

### Analyze: `Analyze-PsDebug.ps1`

Diffs consecutive timestamps to compute per-statement cost, then sorts by slowest:

```powershell
param(
    $Log = "$env:TEMP\ps-profile-psdebug.log"
)

$entries = Get-Content $Log |
    Where-Object { $_ -match '^\s*([\d\.]+)\s+ms\s+(.*)$' } |
    ForEach-Object {
        [pscustomobject]@{
            Time = [double]$Matches[1]
            Cmd  = $Matches[2].Trim()
        }
    }

$timed = for ($i = 1; $i -lt $entries.Count; $i++) {
    [pscustomobject]@{
        DurationMs = $entries[$i].Time - $entries[$i-1].Time
        Command    = $entries[$i-1].Cmd
    }
}

"=== Top 25 slowest statements ==="
$timed |
    Sort-Object DurationMs -Descending |
    Select-Object -First 25 |
    Format-Table DurationMs, Command -AutoSize

"=== Accumulated cost per command (death by 1000 cuts) ==="
$timed |
    Group-Object Command |
    ForEach-Object {
        [pscustomobject]@{
            Command = $_.Name
            TotalMs = ($_.Group | Measure-Object DurationMs -Sum).Sum
            Count   = $_.Count
        }
    } |
    Sort-Object TotalMs -Descending |
    Select-Object -First 20 |
    Format-Table -AutoSize
```

The "accumulated cost" section catches patterns like a helper function called 50 times that's fine individually but dominates in aggregate.

### Common culprits

| Pattern | Why it's slow |
| --- | --- |
| `Import-Module` | Disk scan + module auto-loading |
| oh-my-posh / prompt init | Git status, JSON parsing, file IO |
| `$env:PATH +=` in a loop | Repeated string reallocation |
| `Get-ChildItem` | Antivirus + filesystem |
| Git calls | Fork/exec + repo scan |
| Network drives | UNC latency |

See also [[shell.prompt]] for debugging a slow *per-command* prompt (different problem: `oh-my-posh debug`).

### Fixes

**Slow `Import-Module`** — lazy-load on first use:

```powershell
$ExecutionContext.InvokeCommand.CommandNotFoundAction = {
    param($CommandName, $CommandLookupEventArgs)
    if ($CommandName -eq 'git-foo') {
        Import-Module posh-git
        $CommandLookupEventArgs.StopSearch = $true
    }
}
```

**oh-my-posh init** — use a minimal config while profiling to isolate whether it's the init call or a specific segment. See [[shell.prompt#debugging prompt being slow]].

**Cleanup** — once done, remove the three instrumentation lines from `$PROFILE`. No state persists between sessions.
