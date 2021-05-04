<#
.SYNOPSIS
Outputs i.e. master or main
#>

$remoteDefault = (git remote show origin) -match "HEAD " -split " " | select -Last 1

git config --default $remoteDefault my.default.branch
