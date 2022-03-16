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

git fetch --recurse-submodules=false
git --no-pager log HEAD --not origin/$(Get-GitDefaultBranch) --format=%B%n --reverse

git push -u
gh pr create --web
