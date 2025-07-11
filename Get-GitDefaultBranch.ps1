# Get-GitDefaultBranch.ps1
<#
.SYNOPSIS
Outputs i.e. master or main
.PARAMETER Refresh
If specified, the default branch is refreshed from the remote.
#>

param (
    [switch] $Refresh = $false
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# Setup cache directory following XDG spec
$cacheDir = if ($IsWindows) {
    Join-Path $env:LOCALAPPDATA "git-utils/cache"
} else {
    Join-Path $HOME ".cache/git-utils"
}

# Ensure cache directory exists
if (!(Test-Path $cacheDir)) {
    New-Item -ItemType Directory -Force $cacheDir | Out-Null
}

# Generate unique ID for this repo
$repoPath = git rev-parse --git-dir
$repoId = (Get-FileHash $repoPath).Hash.Substring(0, 8)
$cacheFile = Join-Path $cacheDir "default-branch-$repoId.json"

if (!$Refresh -and (Test-Path $cacheFile)) {
    try {
        $cache = Get-Content $cacheFile -Raw | ConvertFrom-Json
        # Cache expires after 7 days
        if ([DateTime]::UtcNow - [DateTime]::Parse($cache.timestamp) -lt [TimeSpan]::FromDays(7)) {
            return $cache.branch
        }
    } catch {
        Write-Verbose "Cache read failed, ignoring: $_"
    }
}

$remoteDefault = (git remote show origin) -match "HEAD " -split " " | Select-Object -Last 1

# Cache the result
@{
    branch = $remoteDefault
    timestamp = [DateTime]::UtcNow.ToString('o')
} | ConvertTo-Json | Set-Content $cacheFile

return $remoteDefault
