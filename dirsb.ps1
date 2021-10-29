<#
.SYNOPSIS
Like dir /s /b
.DESCRIPTION
More description
.PARAMETER File
Param 1
.INPUTS
Pipe something?
.OUTPUTS
Prints something fancy?
.EXAMPLE
PS> .\Script.ps1 foobar
#>

param(
    [string] $File = $null
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

Get-ChildItem -Recurse $File | ForEach-Object FullName
