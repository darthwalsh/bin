<#
.SYNOPSIS
Runs TagTheKeep
.DESCRIPTION
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

cd ~/code/TagTheKeep
. ./env/bin/Activate.ps1
python main.py -u darthwalsh
deactivate
