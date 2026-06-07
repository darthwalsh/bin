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

# Try to prevent crash piping later: Process must exit before requested information can be determined... `GitLog| Out-String` didn't work
$tmp = [System.IO.Path]::GetTempFileName()
GitLog > $tmp
Get-Content $tmp | Set-Clipboard
Get-Content $tmp | Select-String -Pattern 'AFTER_MERGE' -Context 3

$remote = Get-GitDefaultBranchRemote
[int]$behind, [int]$ahead = (git rev-list --left-right --count "$remote/$(Get-GitDefaultBranch)...HEAD") -split '\s'
if ($behind) {
  Write-Warning "Branch is behind $remote/$(Get-GitDefaultBranch) by $behind commits"
  gitrb -ForcePush
}

git push -u

if (!$create) {
  Write-Warning "Close this browser tab after, because gh-pr-status.py is tracking PRs status in posh prompt"
  gh pr create --web
  return
}

$reviewerUsernames = @(Get-DefaultReviewer) # Need to create this in your profile

if ($ahead -ne 1) {
  # If multiple commits --fill-verbose combines each PR message into bulleted list, and builds an OK title from the branch name (but not using - in the jira ticket, oops)
  throw "Multiple commits causes --fill-verbose to give wrong title, so need to split `$tmp into --title --body, or maybe open local text editor??"
}

$dry = @(if ($WhatIfPreference) { '--dry-run' })

# Create PR WITHOUT reviewers; we add them only after CI passes to reduce reviewer noise.
# If we crash or the terminal dies before adding reviewers, gh-pr-status.py shows 🙋
# (NEEDS_REVIEWER) in the posh prompt so it's not lost.
gh pr create --fill-verbose @dry --base $(Get-GitDefaultBranch)

try {
  gh pr merge --auto --squash
} catch {
  Write-Warning "Failed to enable auto-merge"
}

if ($WhatIfPreference) {
  Write-Host "Skipping jenk -Wait + add-reviewer under -WhatIf"
  return
}

if (Test-Path (Join-Path (git rev-parse --show-toplevel) 'Jenkinsfile')) {
  # Block until Jenkins CI completes; throws on failure leaving the PR reviewer-less on purpose.
  jenk -Wait -Verbose
} else {
  Write-Warning "Not in a Jenkins project; skipping jenkins check"
}

if ($reviewerUsernames) {
  $addReviewerArgs = $reviewerUsernames | ForEach-Object { '--add-reviewer', $_ }
  gh pr edit @addReviewerArgs
} else {
  Write-Warning "Get-DefaultReviewer returned nothing; PR has no reviewer assigned (gh-pr-status will alert)"
}

Write-Verbose "Not running gh pr view --web because gh-pr-status.py is tracking PRs status in posh prompt"
