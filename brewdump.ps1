<#
.SYNOPSIS
Dump brew packages to github
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$brewfile = Join-Path (Get-Bin) apps Brewfile
write-host "Writing to $brewfile" -ForegroundColor Blue
brew bundle dump --no-upgrade --describe --force --taps --casks --brews --mas "--file=$brewfile"
