<#
.SYNOPSIS
cd to the git folder
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

cd (git rev-parse --show-toplevel)
