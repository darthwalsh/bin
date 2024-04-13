<#
.SYNOPSIS
Runs git push and pr creation
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

try {
  gh pr view --web
  return
}
catch {
  Write-Verbose "Ignoring native command error"
}

$status = Get-GitStatus
if ($status.HasWorking) {
  Write-Warning ($status.Working -join " ")
  throw "Working tree is dirty"
}

git fetch --recurse-submodules=false
git --no-pager log HEAD --not origin/$(Get-GitDefaultBranch) --format=%B%n --reverse

git push -u

Write-Host "TODO consider setting the body" -ForegroundColor Blue
# For multiple commits, the git log output above is what the body should be

gh pr create --web
