<#
.SYNOPSIS
Returns pipeline $input from stdin, or clipboard contents as fallback.
#>


$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$piped = @($input)
if ($piped.Count -gt 0) { return $piped }

$clip = Get-Clipboard
Write-Host "Pasted: " -NoNewline
Write-Host $clip -ForegroundColor Blue
return $clip
