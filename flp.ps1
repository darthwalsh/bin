<#
.SYNOPSIS
Print all properties of an object
#>

param(
    [Parameter(ValueFromPipeline, Mandatory=$true)]
    $o
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

Write-Host "-------------------------------- Static --------------------------------" -ForegroundColor Blue

$o | get-member -static | Select-Object Definition | Out-Host 

Write-Host "-------------------------------- Instance --------------------------------" -ForegroundColor Blue

$o | Format-List -Property * | Out-Host

Write-Host "-------------------------------- [$($o.GetType().FullName)] --------------------------------" -ForegroundColor Blue
