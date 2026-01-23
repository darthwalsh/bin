<#
.SYNOPSIS
Copies stdin/clipboard to obsidian inbox tomorrow
.DESCRIPTION
Tomorrow's note avoids OneDrive sync conflicts vs. phone
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$File = Join-Path ~/notes/MyNotes/inbox "$(ymd -Days 1).md"
If (Test-Path $File) {
  "`n`n" >> $File
}
@($input) | Get-InputOrClipboard >> $File
$File
