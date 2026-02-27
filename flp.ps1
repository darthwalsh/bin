<#
.SYNOPSIS
Print all properties of an object
.DESCRIPTION
MAYBE implement flp.Dump.PLAN.md to improve formatting for scalars?
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
