<#
.SYNOPSIS
Outputs remote to use for default branch i.e. origin or upstream
.DESCRIPTION
Always use this instead of hardcoding "origin/$(Get-GitDefaultBranch)"!
Doesn't need a remote query or caching, just a git config lookup.
#>

param (
  [switch] $Refresh = $false
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

git config branch.$(Get-GitDefaultBranch).remote
