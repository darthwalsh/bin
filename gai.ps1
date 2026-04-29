<#
.SYNOPSIS
git commit the staged files, marking author as AI
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

git commit --author="AI <ai@local>" -m "AI generated"
