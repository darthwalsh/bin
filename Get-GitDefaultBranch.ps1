<#
.SYNOPSIS
Outputs i.e. master or main
.PARAMETER Refresh
If specified, the default branch is refreshed from the remote.
#>

param (
    [switch] $Refresh = $false
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

if (!$Refresh) {
  try {
    git config my.default.branch
    return
  } catch {
    Write-Verbose "Ignoring native command error"
  }
}

$remoteDefault = (git remote show origin) -match "HEAD " -split " " | select -Last 1

git config my.default.branch $remoteDefault
$remoteDefault
