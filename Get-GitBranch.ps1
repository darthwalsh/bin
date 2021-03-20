<#
.SYNOPSIS
Return git branch
#>


$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

git rev-parse --abbrev-ref HEAD 
