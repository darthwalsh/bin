<#
.SYNOPSIS
Converts DateTime to YYYY-MM-DD
.EXAMPLE
PS> gi ~ | % LastWriteTime | ymd
#>

param(
    [Parameter(ValueFromPipeline, Mandatory=$true)]
    [DateTime] $Date
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$Date.ToString('yyyy-MM-dd')
