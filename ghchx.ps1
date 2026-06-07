<#
.SYNOPSIS
Get github check status for PR
.DESCRIPTION
Similar to `gh pr checks $n` but opens links for required checks that are failing.
For checks hosted on cloudbees instances I don't have access to,
falls back to the GitHub check_run URL which renders the output inline.
.PARAMETER n
PR number, inferred from current branch if not provided
.PARAMETER repo
Optional string: owner/username
.PARAMETER optional
Include optional and required checks.
.PARAMETER PassThru
Don't open links: render each failing check's output markdown to the terminal via glow.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
  [int] $n = $null,
  [string] $repo = $null,
  [switch] $optional = $false,
  [switch] $PassThru = $false
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# Only some controllers are accessible to me; for other cloudbees hosts
# the upstream link is useless, so prefer the GitHub check page (which embeds the output).
$accessibleCloudbees = Get-Content ~/.config/ghchx/cbci.txt  # You need to create this!

if (-not $n) {
  $n = gh pr view --json number  | jq -r .number
}
$repoArgs = if ($repo) { @("--repo", $repo) } else { @() }

# Resolve PR head SHA + URL so we can fetch check-runs (output markdown + check_run_id).
$pr = gh @repoArgs pr view $n --json headRefOid, url | ConvertFrom-Json
$ownerRepo = ($pr.url -split '/')[3..4] -join '/' # MAYBE this is just {owner}/{repo}?
$checkRuns = (gh @repoArgs api "repos/$ownerRepo/commits/$($pr.headRefOid)/check-runs?per_page=100" | ConvertFrom-Json).check_runs

# https://cli.github.com/manual/gh_pr_checks
$required = @(if (-not $optional) { "--required" })
$checks = gh @repoArgs pr checks $n @required --json 'name,bucket,link' | ConvertFrom-Json
foreach ($check in $checks) {
  $link = $check.link
  if ($link.StartsWith('https://app.snyk.io/')) {
    Write-Warning "Skipping Snyk, consider fixing: $link"
    continue
  }
  $color = if ($check.bucket -in @("fail", "cancel")) { "Red" } elseif ($check.bucket -in @("success", "pass")) { "Green" } else { "Gray" }
  Write-Host "Check $($check.name) $($check.bucket), see $link" -ForegroundColor $color
  if ($color -ne "Red") { continue }

  $run = $checkRuns | Where-Object name -eq $check.name | Select-Object -First 1

  if ($PassThru) {
    if (-not $run) {
      Write-Warning "No check-run found for $($check.name); cannot render output"
      continue
    }
    $output = $run.output
    $md = ''
    if ($output.psobject.properties['title']?.Value) { $md += "## $($output.title)`n`n" }
    if ($output.psobject.properties['summary']?.Value) { $md += "$($output.summary)`n`n" }
    if ($output.psobject.properties['text']?.Value) { $md += $output.text }
    if (-not $md) {
      Write-Warning "No output text for check $($check.name)"
      continue
    }
    $md | glow -w 0
    continue
  }

  # Default: open the link, but for inaccessible cloudbees hosts, open the GitHub check page instead.
  $target = $link
  if ($link -match '^https://(c\d+)\.cloudbees-ci' -and $Matches[1] -notin $accessibleCloudbees) {
    if ($run) {
      $target = "$($pr.url)/checks?check_run_id=$($run.id)"
      Write-Host "  -> $($Matches[1]) not accessible, opening $target" -ForegroundColor Yellow
    }
    else {
      Write-Warning "Cloudbees $($Matches[1]) not accessible and no GitHub check-run match for $($check.name)"
    }
  }
  Start-Process $target
}
