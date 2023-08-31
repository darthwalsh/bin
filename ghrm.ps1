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

$defBranch = Get-GitDefaultBranch
$branches = @{}
foreach ($line in git branch --format='%(refname:short) %(objectname)') {
  $name, $hash = $line -split ' '
  if ($name -eq $defBranch) { continue }
  $branches[$name] = $hash
}


$query = $branches.Keys | % { "head:$_" } | Join-String -Separator ' '
$result = gh pr list --search $query --state all --json 'commits,state' | ConvertFrom-Json
write-warning "TODO should filter that the local branch name exactly matches the PR branch" # TODO 

$commit2status = @{}
foreach ($r in $result) {
  foreach ($c in $r.commits) {
    $commit2status[$c.oid] = $r.state
  }
}

foreach ($b in $branches.GetEnumerator() | Sort-Object -Property Name) {
  $status = $commit2status[$b.Value] ?? "no-pr"
  if ($status -eq 'no-pr') { continue }

  $color = switch ($status) {
    # "no-pr" { "Gray" }
    "OPEN" { "DarkYellow" }
    "CLOSED" { "DarkRed" }
    "MERGED" { "DarkGreen" }
    default { "White" }
  }
  write-host ($b.Key + ": " + $status) -ForegroundColor $color
}

foreach ($b in $branches.GetEnumerator() | Sort-Object -Property Name) {
  if ($commit2status[$b.Value] -ne 'MERGED') { continue }
  $toDelete = $b.Key

  if ($toDelete -eq $defBranch) {
    throw "Can't delete default branch $Branch"
  }
  if ($toDelete -eq (Get-GitBranch)) {
    git checkout $defBranch
    git pull --recurse-submodules=false
  }

  DeleteLocalRemoteGitBranch $toDelete
}
  