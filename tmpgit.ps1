<#
.SYNOPSIS
Sets up a temporary git repo for testing
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

pushtmp
git clone git@github.com:darthwalsh/oss.git
cd oss

touch a.txt
git add a.txt
