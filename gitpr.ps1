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

git fetch
git --no-pager log HEAD --not origin/develop --format=%B%n --reverse

git push -u
gh pr create --web
