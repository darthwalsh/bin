<#
.SYNOPSIS
rm GitHub branches that have been merged
.DESCRIPTION
Searches local branches for matching GitHub PRs.
Delete local&remote branches that match a merged PR.

git branch --merged doesn't play well with squash commits: https://stackoverflow.com/a/19309568/771768
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$branches = git branch --format='%(refname:short)'
$query = $branches | % { "head:$_" } | Join-String -Separator ' '
$result = gh pr list --search $query --state all --json 'state,headRefName' | ConvertFrom-Json

if ($ENV:GHRM_DEBUG) {
  git branch --format='%(refname:short) %(objectname)'
  ""

  $result = gh pr list --search $query --state all --json 'commits,state,headRefName' | ConvertFrom-Json
  foreach ($r in $result) {
    foreach ($c in $r.commits) {
      $commit2status[$c.oid] = $r.state
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

$defBranch = Get-GitDefaultBranch
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
    git checkout $defBranch
    git pull --recurse-submodules=false
  }

  DeleteLocalRemoteGitBranch $toDelete -ignoreRemoteNotFound
}
  