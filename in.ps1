<#
.SYNOPSIS
Copies stdin to obsidian inbox
.PARAMETER Name
#>

param(
    [string] $Name
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

if (-not $Name) {
  $Name = (Get-Date).ToString("yyyy-MM-dd")
}
if (-not $Name.EndsWith(".md")) {
  $Name += ".md"
}

$File = Join-Path ~/notes/MyNotes/inbox $Name
If (Test-Path $File) {
  "`n`n" >> $File
}
$Input >> $File
$File
