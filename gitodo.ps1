<#
.SYNOPSIS
For a PR, find any TODO that has changed
#>

param (
    [Parameter()]
    $ref=""
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

if ($ref -eq "") {
    $ref = "origin/$(Get-GitDefaultBranch)"
}

git diff --unified=0 --color --no-prefix $ref | Select-String 'TODO|---'
