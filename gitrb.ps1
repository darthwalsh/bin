<#
.SYNOPSIS
Rebase changes onto origin/develop
.DESCRIPTION
Might be upstream/staging, etc, based on defaults
#>

param(
    [switch]$ForcePush
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

git fetch --recurse-submodules=false $(Get-GitDefaultBranchRemote)
git rebase "$(Get-GitDefaultBranchRemote)/$(Get-GitDefaultBranch)"

if ($ForcePush) {
    git push --force-with-lease --force-if-includes
}
