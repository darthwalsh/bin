<#
.SYNOPSIS
Pastes clipboard contents to a temp file
.PARAMETER File
Name of a file, appends .md if not present
#>

param(
    [Parameter(Mandatory=$true)]
    [string] $File
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

if ($File -notmatch '\.\w{2,4}$') {
    $File += '.md'
}
$temp = Join-Path (Convert-Path Temp:\) $File

$clip = Get-Clipboard
Set-Content $temp $clip

$temp | Set-Clipboard
$temp
