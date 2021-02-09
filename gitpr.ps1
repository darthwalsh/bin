<#
.SYNOPSIS
Runs git push and pr creation
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest


git push -u
gh pr create --web
