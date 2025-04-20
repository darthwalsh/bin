<#
.SYNOPSIS
Shows jira sprint and branches off develop
.PARAMETER BranchName
Branch name to create
.PARAMETER SkipJira
Don't transition Jira issue to In Progress
#>

[CmdletBinding()]
param (
    [Parameter()]
    [string] $BranchName,
    [switch] $SkipJira = $false
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

if (-not $BranchName) {
  jspr
  $BranchName = Read-Host -Prompt "branch name"
}
if ($BranchName -cmatch '^[A-Z]{2,4}-\d+$') {
  Write-Warning "Updating branch name to include summary..."
  $BranchName = jsum $BranchName -Branch
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

if (!$SkipJira -and $BranchName -match '^\w+-\d+[_-]') {
  $issue = $matches[0].TrimEnd('_','-')
  $o = jira view $issue -t json | ConvertFrom-Json

  $shouldOwn = if (!$o.fields.assignee) {
    $response = Read-Host "Take ownership of unassigned Jira issue? (y/N)"
    $response -eq "y"
  } else {
    $o.fields.assignee.name -eq 'walshca'
  }
  
  if ($o.fields.status.name -match 'New|Prioritized Backlog|Ready for Grooming|Sprint Ready' -and $shouldOwn) {
    try {
      jira transition 'In Progress' $issue --noedit
      jira assign $issue walshca
    } catch {
      Write-Warning $_.Exception.Message
    }
  }
}

code (git rev-parse --show-toplevel)
