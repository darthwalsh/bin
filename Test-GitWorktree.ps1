<#
.SYNOPSIS
Returns $true if the current (or specified) path is a git linked worktree.

A linked worktree has a per-worktree .git/worktrees/<name> dir, so --git-dir
differs from --git-common-dir. For main worktrees and non-repos, they are equal
(or both empty), so this returns $false.
.PARAMETER Path
Directory to check. Defaults to current directory.
.OUTPUTS
boolean
#>

param(
    [string] $Path = '.'
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

Push-Location $Path
try {
    $gitDir    = git rev-parse --git-dir 2>$null
    $commonDir = git rev-parse --git-common-dir 2>$null
    [bool]($gitDir -and $gitDir -ne $commonDir)
} catch {
  $false
} finally {
    Pop-Location
}
