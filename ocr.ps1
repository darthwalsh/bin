<#
.SYNOPSIS
Captures current clipboard to OCR and returns the text.
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$winocr = Get-Command winocr | % Source
powershell.exe -nop -command $winocr
