<#
.SYNOPSIS
Print my git commits
#>


$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

git log --oneline --author (git config user.name) --name-only 
