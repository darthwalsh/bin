<#
.SYNOPSIS
Output strava cookies
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$py = 'python'
$pp = '~/pye_nv/bin/python'
if (test-path $pp) {
  $py = $pp
}
<# Expected requirements
stravacookies==1.3
firebase-admin==6.3.0
#>

. $py (Join-Path $PSScriptRoot strava_cook.py)
