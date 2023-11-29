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
git pull --recurse-submodules=false

if (-not $BranchName) {
  jspr
  $BranchName = Read-Host -Prompt "branch name"
}

git checkout -b $BranchName

write-host "IDEA! transition jira issue to In Progress if in New / Prioritized Backlog / Ready for Grooming etc" -foregroundcolor blue
<#
$ jira transition 'In Progress' QTZ-729
? No changes detected, submit anyway? Yes
OK QTZ-729 https://jira.autodesk.com/browse/QTZ-729
#>
