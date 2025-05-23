<#
.SYNOPSIS
WIP Run a bash script on your clipboard
.DESCRIPTION
Fixes backslash line continuation issues
MAYBE re-write env var from $VAR to $env:VAR
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

raise "WIP"

$clip = Get-Clipboard
$clip = $clip -replace '\\\r?\n', ' '
$clip
