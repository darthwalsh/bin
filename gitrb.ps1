<#
.SYNOPSIS
Rebase changes onto origin/develop
#>

param(
    [switch]$ForcePush
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

git fetch --recurse-submodules=false
git rebase "origin/$(Get-GitDefaultBranch)"

if ($ForcePush) {
    git push --force-with-lease --force-if-includes
}
