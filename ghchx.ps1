<#
.SYNOPSIS
WIP script for get github check status for PR, similar to gh pr checks $n
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
if (-not $repo) {
  $repo = '{owner}/{repo}'
}

$statusesUrl = gh api "/repos/$repo/pulls/$n" --jq .statuses_url
$statuses = gh api $statusesUrl | ConvertFrom-Json

# TODO get statues from gh pr checks 581 --required --json bucket,completedAt,description,event,link,name,startedAt,state,workflow
# Was trying to use: gh pr view 581 --json statusCheckRollup --jq ".statusCheckRollup" might be better
#   then maybe would check .conclusion or .state

if ($action) {
  $statuses | ? state -ne 'success'
} else {
  $statuses
}
