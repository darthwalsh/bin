<#
.SYNOPSIS
Does file start with a shebang
.PARAMETER File
Script
#>

param(
    [Parameter(Mandatory=$true)]
    [string] $File
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$bytes = Get-Content $File -AsByteStream -TotalCount 2
'#!' -eq -join [char[]]$bytes
