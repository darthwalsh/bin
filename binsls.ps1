<#
.SYNOPSIS
Seach for text in this bin folder
.DESCRIPTION
Args are same as Select-String: -Pattern -Context -Raw etc.
#>

# param(
#     [Parameter(Mandatory=$true)]
#     [string] $Pattern
# )

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

Get-ChildItem -Recurse $PSScriptRoot | Select-String @args
