<#
.SYNOPSIS
Copies stdin/clipboard to Projects.My
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$File = "~/notes/MyNotes/Projects.My.md"
"" >> $File
Get-InputOrClipboard >> $File
$File
