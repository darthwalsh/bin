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
$log = GitLog
$log
$log | Set-Clipboard


Write-Host "TODO check the branch is rebased on origin/$(Get-GitDefaultBranch)" -ForegroundColor Blue # TODO
git push -u

gh pr create --web
# MAYBE trying setting the --body $log, but I think it's not supported with --web?
