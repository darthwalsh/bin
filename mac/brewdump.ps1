<#
.SYNOPSIS
Dump brew packages to current github repo
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$brewfile = Join-Path (Get-Bin) apps Brewfile
write-host "Writing to $brewfile" -ForegroundColor Blue
brew bundle dump --no-upgrade --describe --force --taps --casks --brews --mas "--file=$brewfile"
# MAYBE instead include all, if --no-vscode implemented https://github.com/Homebrew/homebrew-bundle/issues/1212#issuecomment-1570684920

Write-Host "MAYBE Next step, run npx share-brewfiles?" -ForegroundColor Yellow # TODO
