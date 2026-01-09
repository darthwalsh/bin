<#
.SYNOPSIS
Get all git projects that I might want to automate
.DESCRIPTION
Override in other projects as needed.
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

gi ~/code/*/.git -force | % Parent
