<#
.SYNOPSIS
git log --oneline --decorate --all --graph
.DESCRIPTION
Skips over renovate commits
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

git log --oneline --decorate --all --graph | sls -notmatch ' Update dependency '

