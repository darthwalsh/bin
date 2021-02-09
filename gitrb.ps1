<#
.SYNOPSIS
Rebase changes onto origin/develop
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

git fetch
git rebase "origin/$(Get-GitDefaultBranch)"
