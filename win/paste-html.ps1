<#
.SYNOPSIS
Paste HTML from clipboard
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

Write-Warning "Not tested -- #ai-slop. What about error if only plaintext?"
Get-Clipboard -Format Html
