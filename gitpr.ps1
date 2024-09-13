<#
.SYNOPSIS
Runs git push and pr creation
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$status = Get-GitStatus
if ($status.HasWorking) {
  Write-Warning ($status.Working -join " ")
  throw "Working tree is dirty"
}

function GitLog {
  git --no-pager log HEAD --not origin/$(Get-GitDefaultBranch) --format=%B%n --reverse
}

try {
  gh pr view --web
  git push
  GitLog
  return
}
catch {
  Write-Verbose "Ignoring native command error"
}

git fetch --recurse-submodules=false
GitLog

Write-Host "TODO check the branch is rebased on origin/$(Get-GitDefaultBranch)" -ForegroundColor Blue # TODO
git push -u

Write-Host "TODO set the PR body" -ForegroundColor Blue # TODO
# For multiple commits, the git log output above is what the body should be

gh pr create --web
