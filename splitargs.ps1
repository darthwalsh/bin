<#
.SYNOPSIS
Splits the args showing how powershell parses args
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$args | ForEach-Object { ">|$_|<"}
