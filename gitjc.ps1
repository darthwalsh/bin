<#
.SYNOPSIS
Shows jira sprint and branches off develop
#>

[CmdletBinding()]
param (
    [Parameter()]
    [string] $BranchName
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$defBranch = Get-GitDefaultBranch
git checkout $defBranch
git pull

if (-not $BranchName) {
  jspr
  $BranchName = Read-Host -Prompt "branch name"
}

git checkout -b $BranchName
