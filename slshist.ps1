<#
.SYNOPSIS
Searches HistorySavePath
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

Select-String -Path (Get-PSReadlineOption).HistorySavePath @args
