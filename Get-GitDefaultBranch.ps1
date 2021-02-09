<#
.SYNOPSIS
Outputs i.e. master or main
#>

(git remote show origin) -match "HEAD " -split " " | select -Last 1
