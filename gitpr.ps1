<#
.SYNOPSIS
Runs git push and pr creation
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

gh pr view --web
$prExists = -not $LASTEXITCODE

$status = Get-GitStatus
if ($status.HasWorking) {
  Write-Warning ($status.Working -join " ")
  throw "Working tree is dirty"
}

git fetch --recurse-submodules=false
git --no-pager log HEAD --not origin/$(Get-GitDefaultBranch) --format=%B%n --reverse

git push -u
if (-not $prExists) {
  gh pr create --web
}
