<#
.SYNOPSIS
Deletes the current branch and returns to the default branch.
#>

[CmdletBinding(SupportsShouldProcess)]
param()

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$current = git symbolic-ref --short HEAD
if ($PSCmdlet.ShouldProcess($current, "Delete $current and switch to default branch")) {
    git checkout (Get-GitDefaultBranch)
    git branch --delete --force $current
}
