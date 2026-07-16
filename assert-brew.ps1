<#
.SYNOPSIS
Checks that brew autoupdate is healthy. #ai-slop
.DESCRIPTION
See brew.md: brew should auto-update in the background every 24 hours.
Checks daemon status, in-progress build state, last formula built, and last-run errors.
.OUTPUTS
Writes warnings for problems; exits 0 if healthy or in-progress.
.EXAMPLE
./assert-brew.ps1
./assert-brew.ps1 -MaxAgeHours 72
#>

param(
    [string] $LogFile    = "$env:HOME/Library/Logs/com.github.domt4.homebrew-autoupdate/com.github.domt4.homebrew-autoupdate.out",
    [string] $BrewLogDir = "$env:HOME/Library/Logs/Homebrew",
    [int]    $MaxAgeHours = 48
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$warnings = [System.Collections.Generic.List[string]]::new()

# --- 1. Daemon configured ---
$status = (brew autoupdate status 2>&1) -join "`n"
if ($status -notmatch "Autoupdate is installed and running") {
    $warnings.Add("brew autoupdate is not running. Run: brew autoupdate start --upgrade --immediate --no-notify")
}

# --- 2. In-progress detection ---
# Extract "borgbackup-fuse" from: build.rb .../Formula/borgbackup-fuse.rb --verbose
# macOS BSD pgrep does not support GNU long flags, so short flags -lf/-f are required
$buildProc = try { pgrep -lf "build.rb" 2>/dev/null | Where-Object { $_ -match 'Formula/(.+?)\.rb' } } catch { $null }
$upgradeProc = try { pgrep -f "brew.rb upgrade" 2>/dev/null } catch { $null }

if ($upgradeProc -and $buildProc) {
    $formula = if ($buildProc -match 'Formula/(.+?)\.rb') { $Matches[1] } else { "unknown" }
    $upgradePid = ($upgradeProc | Select-Object -First 1).Trim()
    $elapsed = (bash -c "ps -p $upgradePid -o etime= 2>/dev/null").Trim()
    Write-Host "⏳ brew upgrade in progress for $elapsed — currently building: $formula"
    Write-Host "   Watch: tail -f $LogFile"
} elseif ($upgradeProc) {
    $upgradePid = ($upgradeProc | Select-Object -First 1).Trim()
    $elapsed = (bash -c "ps -p $upgradePid -o etime= 2>/dev/null").Trim()
    Write-Host "⏳ brew upgrade in progress for $elapsed (between packages)"
}

# --- 3. Last formula built (from Homebrew's own build logs) ---
if (Test-Path $BrewLogDir) {
    $lastBuilt = Get-ChildItem $BrewLogDir -Directory |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1
    if ($lastBuilt) {
        $age = (Get-Date) - $lastBuilt.LastWriteTime
        $ageStr = if ($age.TotalHours -lt 1) { "$([int]$age.TotalMinutes)m ago" }
                  elseif ($age.TotalDays -lt 1) { "$([int]$age.TotalHours)h ago" }
                  else { "$([int]$age.TotalDays)d ago" }
        Write-Host "📦 Last formula built: $($lastBuilt.Name) ($ageStr)"
    }
}

# --- 4. Autoupdate log: age + last-run errors ---
if (-not (Test-Path $LogFile)) {
    $warnings.Add("Autoupdate log not found: $LogFile")
} else {
    $logAge = (Get-Date) - (Get-Item $LogFile).LastWriteTime
    if ($logAge.TotalHours -gt $MaxAgeHours) {
        $warnings.Add("Autoupdate log not updated in $([int]$logAge.TotalHours)h (threshold: ${MaxAgeHours}h) — autoupdate may be stuck")
    }

    # Find the last run's timestamp header, check what followed it
    $lines = @(Get-Content $LogFile)
    $lastRunStart = -1
    for ($i = $lines.Count - 1; $i -ge 0; $i--) {
        if ($lines[$i] -match '^\w{3} \w{3} +\d+ \d{2}:\d{2}:\d{2} \w+ \d{4}$') {
            $lastRunStart = $i
            break
        }
    }

    if ($lastRunStart -ge 0) {
        $lastRunLines = $lines[$lastRunStart..($lines.Count - 1)]
        $runTimestamp  = $lines[$lastRunStart]

        if ($lastRunLines | Where-Object { $_ -match 'Killed: \d+' }) {
            $warnings.Add("Last autoupdate run ($runTimestamp) was killed mid-upgrade (a package build hung)")
        }

        # Capture the full multi-line error block, not just the "Error:" header line —
        # brew explains each failed cask/formula on the lines that follow, up to the next "==>" section.
        for ($i = 0; $i -lt $lastRunLines.Count; $i++) {
            if ($lastRunLines[$i] -notmatch '^Error:') { continue }
            $endIdx = $lastRunLines.Count - 1
            for ($j = $i + 1; $j -lt $lastRunLines.Count; $j++) {
                if ($lastRunLines[$j] -match '^==>') { $endIdx = $j - 1; break }
            }
            $errorBlock = ($lastRunLines[$i..$endIdx] -join "`n").TrimEnd()
            $warnings.Add("Last autoupdate run ($runTimestamp) had brew error:`n$errorBlock")
            $i = $endIdx
        }
    }
}

# --- Report ---
if ($warnings.Count -eq 0) {
    Write-Host "✅ brew autoupdate looks healthy"
} else {
    foreach ($w in $warnings) {
        Write-Warning $w
    }
    exit 1
}
