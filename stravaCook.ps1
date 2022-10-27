<#
.SYNOPSIS
Output strava cookies
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$py = 'python'
$pp = '~/pye_nv/env/bin/python'
if (test-path $pp) {
  $py = $pp
}

. $py (Join-Path $PSScriptRoot strava_cook.py)
