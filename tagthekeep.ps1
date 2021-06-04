<#
.SYNOPSIS
Runs TagTheKeep
.DESCRIPTION
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

Join-Path (Get-Code) TagTheKeep | cd
va
python main.py -u darthwalsh
deactivate
Pop-Location
