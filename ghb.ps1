<#
.SYNOPSIS
Browse github in browser in the current branch (or default if doesn't exist)
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$branch = Get-GitBranch

try {
  git show-branch "remotes/origin/$branch" 2>&1 | out-null
  $branchArgs = @("-b", $branch)
} catch {
  $branchArgs = @()
}

gh browse @branchArgs
