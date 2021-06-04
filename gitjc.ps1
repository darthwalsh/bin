<#
.SYNOPSIS
Shows jira sprint and branches off develop
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$defBranch = Get-GitDefaultBranch
git checkout $defBranch
git pull

jspr
$b = Read-Host -Prompt "branch name"
git checkout -b $b
