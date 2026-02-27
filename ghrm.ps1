<#
.SYNOPSIS
rm GitHub branches that have been merged
.DESCRIPTION
Searches local branches for matching GitHub PRs.
Delete local&remote branches that match a merged PR.

git branch --merged doesn't play well with squash commits: https://stackoverflow.com/a/19309568/771768
#>

[CmdletBinding(SupportsShouldProcess=$true)]
param(
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$defBranch = Get-GitDefaultBranch
# TODO filtering out default branch feels like hack. Maybe want to go back to using the "commit was merged logic" from older version
$branches = git branch --format='%(refname:short)' | Where-Object { $_ -ne $defBranch }

$query = $branches | % { "head:$_" } | Join-String -Separator ' '
$result = gh pr list --search $query --state all --json 'state,headRefName' | ConvertFrom-Json

if ($ENV:GHRM_DEBUG) {
  # This is a bit slow, but useful for debugging
  # Check that the exact commit was actually merged, not just the branch name
  git branch --format='%(refname:short) %(objectname)'
  ""

  $result = gh pr list --search $query --state all --json 'commits,state,headRefName' | ConvertFrom-Json
  foreach ($r in $result) {
    foreach ($c in $r.commits) {
      foreach ($a in $c.authors) {
        "$($r.state) $($r.headRefName) -- $($c.oid.SubString(0, 6)) $($a.login) $($c.messageHeadline)"
      }
    }
  }
}

Write-Host "TODO git fetch ; gbds..." -ForegroundColor Blue
$sw = [System.Diagnostics.Stopwatch]::StartNew()
git fetch *>&1 | Out-Null
Write-Host "TODO git fetch $($sw.Elapsed.TotalSeconds) seconds" -ForegroundColor Blue
$sw.Restart()
gbds
$sw.Stop()
Write-Host "TODO gbds took $($sw.Elapsed.TotalSeconds) seconds" -ForegroundColor Blue


$branch2status = @{}
foreach ($r in $result) {
  $branch2status[$r.headRefName] = $r.state
}

foreach ($branch in $branches) {
  $status = $branch2status[$branch]
  if (!$status) { continue }

  $color = switch ($status) {
    "OPEN" { "DarkYellow" }
    "CLOSED" { "DarkRed" }
    "MERGED" { "DarkGreen" }
    default { "White" }
  }
  write-host ($branch + ": " + $status) -ForegroundColor $color
  
  if ($status -eq 'CLOSED') {
    git log -1 $branch
    write-host "Maybe Run: git -C $(Get-Location) branch -D $branch" -ForegroundColor DarkYellow
  }
  if ($status -ne 'MERGED') { continue }
  $toDelete = $branch

  if ($toDelete -eq $defBranch) {
    Write-Warning "Skipping deleting default branch $Branch"
    continue
  }

  if ($toDelete -eq 'master') {
    Write-Warning "Skipping deleting master branch"
    git checkout $defBranch
    continue
  }
  if ($toDelete -eq (Get-GitBranch)) {
    git fetch origin "$($defBranch):$defBranch"
    git checkout $defBranch
    
    if (git submodule status) {
      Write-Verbose "Not running git pull --recurse-submodules=false trying to avoid network calls"
      git status -s
      git submodule update --init --recursive
    } else {
      Write-Verbose "No submodules"
    }
  }

  DeleteLocalRemoteGitBranch $toDelete -ignoreRemoteNotFound
}
  