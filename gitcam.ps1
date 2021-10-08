<#
.SYNOPSIS
git commit workspace into recent commit
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

git commit -a --amend --no-edit
