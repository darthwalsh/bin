<#
.SYNOPSIS
Browse github in browser in the current branch (or default if doesn't exist)
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$branch = Get-GitBranch
$branchArgs = @("-b", $branch)

if (-not (git show-branch "remotes/origin/$branch")) {
  $branchArgs = @()
}

gh browse @branchArgs
