<#
.SYNOPSIS
For a PR, find any TODO that has changed
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

git diff --unified=0  "origin/$(Get-GitDefaultBranch)" | Select-String TODO
