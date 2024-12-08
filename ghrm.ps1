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
  
  if ($status -ne 'MERGED') { continue }
  $toDelete = $branch

  if ($toDelete -eq $defBranch) {
    throw "Can't delete default branch $Branch"
  }
  if ($toDelete -eq (Get-GitBranch)) {
    git fetch origin "$($defBranch):$defBranch"
    git checkout $defBranch
    
    Write-Warning "Not running git pull --recurse-submodules=false"
    git submodule update --init --recursive
    Write-Warning "Check that git submodule update --init --recursive worked well"
  }

  DeleteLocalRemoteGitBranch $toDelete -ignoreRemoteNotFound
}
  