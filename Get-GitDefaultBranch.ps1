<#
.SYNOPSIS
Outputs i.e. master or main
#>

git config my.default.branch
if (-not $LASTEXITCODE) { return }

$remoteDefault = (git remote show origin) -match "HEAD " -split " " | select -Last 1

git config my.default.branch $remoteDefault
$remoteDefault
