<#
.SYNOPSIS
Converts DateTime to YYYY-MM-DD
.PARAMETER Date
The date to convert. Defaults to today.
.PARAMETER Time
Also include time in filesystem-friendly format.
.PARAMETER ISO
Include ISO 8601 format.
.EXAMPLE
PS> gi ~ | % LastWriteTime | ymd
#>

param(
    [Parameter(ValueFromPipeline)]
    [DateTime] $Date = (Get-Date),
    [switch] $Time = $false,
    [switch] $ISO = $false
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

if ($ISO) {
    return $Date.ToString('o')
}
if ($Time) {
    return $Date.ToString('yyyy-MM-dd_HH-mm-ss-ff')
}

$Date.ToString('yyyy-MM-dd')
