<#
.SYNOPSIS
Browse github in browser in the current branch
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

gh browse -b (Get-GitBranch)
