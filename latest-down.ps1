<#
.SYNOPSIS
Gets latest file in ~/Downloads
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

gci ~/Downloads | Sort-Object LastWriteTime -Descending | Select-Object -First 1 | fn
