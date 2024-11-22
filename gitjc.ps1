<#
.SYNOPSIS
Shows jira sprint and branches off develop
.PARAMETER BranchName
Branch name to create
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

# Avoid `checkout main; pull; checkout -b` because it does unnecessary works
git fetch
git branch $BranchName "origin/$(Get-GitDefaultBranch)"
git checkout $BranchName
git branch --unset-upstream # Otherwise still tracking origin/main

$executionTime = Measure-Command {
    git submodule update # hopefully this is fast
}
if ($executionTime -gt [TimeSpan]::FromMilliseconds(300)) {
  Write-Warning "Submodule update took $($executionTime.TotalSeconds) seconds"
}

if ($BranchName -match '^\w+-\d+[_-]') {
  $issue = $matches[0].TrimEnd('_','-')
  $o = jira view $issue -t json | ConvertFrom-Json
  
  if ($o.fields.status.name -match 'New|Prioritized Backlog|Ready for Grooming|Sprint Ready' -and (!$o.fields.assignee -or $o.fields.assignee.name -eq 'walshca')) {
    jira transition 'In Progress' $issue --noedit
    jira assign $issue walshca
  }
}

code (git rev-parse --show-toplevel)
