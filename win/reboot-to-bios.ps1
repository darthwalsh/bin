<#
.SYNOPSIS
Reboot straight to BIOS instead of mashing F keys
.DESCRIPTION
From https://youtube.com/shorts/Ky3Uh9dd9bA?si=1EW5dhbqfOuX9ide
.EXAMPLE
PS> .\Script.ps1 foobar
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# Not Tested
shutdown /r /fw /t 1
