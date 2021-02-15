<#
.SYNOPSIS
Finds listening ports
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

sudo lsof -iTCP -sTCP:LISTEN -n -P
