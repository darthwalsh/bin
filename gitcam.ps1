<#
.SYNOPSIS
git commit workspace into recent commit
.PARAMETER ForcePush
Force push to remote
#>

param(
    [switch]$ForcePush
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

git commit -a --amend --no-edit

if ($ForcePush) {
    git push --force-with-lease --force-if-includes
}
