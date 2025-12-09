<#
.SYNOPSIS
Gets a GUID
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

(New-Guid).Guid
