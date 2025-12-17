<#
.SYNOPSIS
Dumps all OS packages
.DESCRIPTION
TODO run this dump from a plist (for windows from windows task scheduler)
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

brewdump
