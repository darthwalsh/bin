<#
.SYNOPSIS
Approve and Merge a PR
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

gh pr review --approve
gh pr merge --auto --squash
