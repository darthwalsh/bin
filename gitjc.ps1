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

if (-not $BranchName) {
  jspr
  $BranchName = Read-Host -Prompt "branch name"
}

$defBranch = Get-GitDefaultBranch
git checkout $defBranch
git pull --recurse-submodules=false
git checkout -b $BranchName

if ($BranchName -match '^\w+-\d+[_-]') {
  $issue = $matches[0].TrimEnd('_','-')
  $o = jira view $issue -t json | ConvertFrom-Json
  
  if ($o.fields.status.name -match 'New|Prioritized Backlog|Ready for Grooming|Sprint Ready' -and (!$o.fields.assignee -or $o.fields.assignee.name -eq 'walshca')) {
    jira transition 'In Progress' $issue --noedit
    jira assign $issue walshca
  }
}

code (git rev-parse --show-toplevel)
