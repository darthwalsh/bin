<#
.SYNOPSIS
Git command for the Bin repo
.DESCRIPTION
All param args forwarded to git
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

git -C (Get-Bin) @args
