<#
.SYNOPSIS
Runs git push and pr creation
.PARAMETER create
Creates the PR instead of opening browser
.PARAMETER allowDirty
Allow the command to run even if the working tree is dirty
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param (
  [switch]$create = $false,
  [switch]$allowDirty = $false
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

try {
  gh pr view --web
  git push
  GitLog
  return
}
catch {
  Write-Verbose "Ignoring native command error"
}

$status = Get-GitStatus
if ($status.HasWorking) {
  Write-Warning ($status.Working -join " ")
  if (!$allowDirty) {
    throw "Working tree is dirty"
  }
}

git fetch --recurse-submodules=false
$log = GitLog
# $log = $log | Out-String # Try to prevent crash piping later: Process must exit before requested information can be determined. -- but didn't work...
$log
$log | Set-Clipboard


[int]$behind, [int]$ahead = (git rev-list --left-right --count "origin/$(Get-GitDefaultBranch)...HEAD") -split '\s'
if ($behind) {
  Write-Warning "Branch is behind origin/$(Get-GitDefaultBranch) by $behind commits"
  gitrb -ForcePush
}

git push -u

if (!$create) {
  gh pr create --web
  return
}

$reviewer = Get-DefaultReviewer # Need to create this in your profile

if ($ahead -ne 1) {
  # If multiple commits --fill-verbose combines each PR message into bulleted list, and builds an OK title from the branch name (but not using - in the jira ticket, oops)
  throw "Multiple commits causes --fill-verbose to give wrong title, so need to split `$log into --title --body, or maybe open local text editor??"
}

$dry = @(if ($WhatIfPreference) { '--dry-run' })

gh pr create @reviewer --fill-verbose @dry --base $(Get-GitDefaultBranch)

try {
  gh pr merge --auto --squash
} catch {
  Write-Warning "Failed to enable auto-merge "
}

gh pr view --web # MAYBE if GitLog doesn't have AFTER_MERGE message, no need to open tab?
