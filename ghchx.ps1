<#
.SYNOPSIS
Get github check status for PR
.DESCRIPTION
Similar to `gh pr checks $n` but opens links for required checks that are failing
.PARAMETER n
PR number
.PARAMETER repo
Optional string: owner/username
#>

param(
  [Parameter(Mandatory=$true)]
  [int] $n = $null,
  [string] $repo = $null,
  [switch] $action = $False
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

if (-not $n) {
  throw "not implemented: getting current-branch PR"
}
$repoArgs = if ($repo) {
  $repoArgs = @("--repo", $repo)
}

# https://cli.github.com/manual/gh_pr_checks
$checks = gh @repoArgs pr checks $n --required --json 'name,bucket,link' | ConvertFrom-Json
foreach ($check in $checks) {
  $link = $check.link
  if ($link.StartsWith('https://app.snyk.io/')) {
    Write-Warning "Skipping Snyk, consider fixing: $link"
    continue
  }
  $color = if ($check.bucket -in @("fail", "cancel")) { "Red" } elseif ($check.bucket -in @("success", "pass")) { "Green" } else { "Gray" }
  Write-Host "Check $($check.name) $($check.bucket), see $link" -ForegroundColor $color
  
  if ($color -eq "Red") { open $link }
}
