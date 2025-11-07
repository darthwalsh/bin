<#
.SYNOPSIS
Create a new temporary obsidian file in inbox/
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$file = (ymd -time) + ".md"
$path = Join-Path ~/notes/MyNotes/inbox $file
New-Item $path -ItemType File | fn

if ($IsWindows) {
  throw "TODO not implemented for windows"
}
$url_encoded = [uri]::EscapeDataString((Resolve-Path $path))
Start-Process "obsidian://open?path=$url_encoded"
