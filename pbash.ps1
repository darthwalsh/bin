<#
.SYNOPSIS
Runs whatever is on the clipboard as bash
.DESCRIPTION
Bash line continuation or custom syntax won't run in powershell...
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

Get-Clipboard | bash
