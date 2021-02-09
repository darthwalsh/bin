<#
.SYNOPSIS
Runs git reset non-hard to default branch
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

git fetch

$b = Get-GitDefaultBranch
git reset origin/$b
