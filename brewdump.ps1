<#
.SYNOPSIS
Dump brew packages to github
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$brewfile = Join-Path (Get-Bin) apps Brewfile
write-host "Writing to $brewfile" -ForegroundColor Blue
Write-Warning "TODO remove vscode https://github.com/Homebrew/homebrew-bundle/issues/1212#issuecomment-1570684920"
brew bundle dump --no-upgrade --describe --force "--file=$brewfile"
