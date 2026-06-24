<#
.SYNOPSIS
git commit the staged files, marking author as AI
#>

param(
  [string] $Message = "AI generated"
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$Message | git commit --author="AI <ai@local>" --file=-
