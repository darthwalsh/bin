<#
.SYNOPSIS
Dump installed chocolatey apps to current github repo
.DESCRIPTION
Requires elevation to prevent file permission messages
#>


$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# MAYBE get PSObject with Description from chocolatey powershell module

$list = choco list --limit-output
$packages = $list | ForEach-Object {
    $split = $_ -split '\|'
    if ($split.Length -ne 2) {
        throw "Unexpected line: $_"
    }
    $split[0]
}

$chocoFile = Join-Path (Get-Bin) win "chocofile-$($ENV:COMPUTERNAME).txt"

Set-Content $chocoFile $packages -Force
"Written to $chocoFile"
