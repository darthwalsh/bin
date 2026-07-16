<#
.SYNOPSIS
Request review from everyone who said "requested changes"
#>

[CmdletBinding(SupportsShouldProcess)]
param()

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$pr = gh pr view --json "latestReviews,number" | ConvertFrom-Json
$n = $pr.number

$reviewers = @($pr.latestReviews | Where-Object state -eq 'CHANGES_REQUESTED' | ForEach-Object { $_.author.login })
if (-not $reviewers) {
  Write-Warning "No reviewers have requested changes on PR $n"
  return
}

Write-Host "Re-requesting review from: $($reviewers -join ', ')" -ForegroundColor Cyan

if ($PSCmdlet.ShouldProcess("PR $n", "Re-request review from $($reviewers -join ', ')")) {
  $body = @{ reviewers = $reviewers } | ConvertTo-Json
  $body | gh api --method POST "repos/{owner}/{repo}/pulls/$n/requested_reviewers" --input - | Out-Null
}
