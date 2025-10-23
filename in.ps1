<#
.SYNOPSIS
Copies stdin to obsidian inbox
.PARAMETER Name
Optional name of the file, otherwise default to today
.INPUTS
Writes input to daily note, or pastes clipboard if no input is provided
#>

param(
    [string] $Name
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

if (-not $Name) {
  $Name = ymd
}
if (-not $Name.EndsWith(".md")) {
  $Name += ".md"
}

$inputContent = @($input)
if ($inputContent.Count -eq 0) {
  $inputContent = Get-Clipboard
}

$File = Join-Path ~/notes/MyNotes/inbox $Name
If (Test-Path $File) {
  "`n`n" >> $File
}
$inputContent >> $File
$File
