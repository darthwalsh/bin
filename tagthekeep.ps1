<#
.SYNOPSIS
Runs TagTheKeep
.DESCRIPTION
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

Push-Location ~/code/TagTheKeep
. ./env/bin/Activate.ps1
python main.py -u darthwalsh
deactivate
Pop-Location
