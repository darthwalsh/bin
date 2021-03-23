<#
.SYNOPSIS
Output strava cookies
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

python (Join-Path $PSScriptRoot strava_cook.py)
