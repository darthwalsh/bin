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

$o | Format-List -Property *
