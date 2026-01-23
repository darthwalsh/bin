<#
.SYNOPSIS
Returns pipeline text, or clipboard contents as fallback.
.EXAMPLE
PS> $text = @($input) | Get-InputOrClipboard
#>


$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$piped = @($input)
if ($piped.Count -gt 0) { return $piped }

$clip = Get-Clipboard
Write-Host "Pasted: " -NoNewline
Write-Host $clip -ForegroundColor Blue
return $clip
