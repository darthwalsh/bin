<#
.SYNOPSIS
git commit workspace into recent commit
.PARAMETER ForcePush
Force push to remote
#>

param(
    [switch]$Edit,
    [switch]$ForcePush
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$edit_arg = if ($Edit) { "--edit" } else { "--no-edit" }

# TODO if anything is staged then don't use -a
git commit -a --amend $edit_arg

if ($ForcePush) {
    git push --force-with-lease --force-if-includes
}
