<#
.SYNOPSIS
Dumps all OS packages
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

chocodump
envdump
scoopdump
wingetdump
