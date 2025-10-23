<#
.SYNOPSIS
Captures current clipboard to OCR and returns the text.
.DESCRIPTION
TODO move to win/
For macOS, see i.e. https://evanhahn.com/mac-ocr-script/ or keep using raycast
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$winocr = Get-Command winocr | % Source
powershell.exe -nop -command $winocr
