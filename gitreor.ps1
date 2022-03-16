<#
.SYNOPSIS
Runs git reset non-hard to default branch
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

git fetch --recurse-submodules=false

$b = Get-GitDefaultBranch
git reset origin/$b
