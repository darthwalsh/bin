<#
.SYNOPSIS
Dump installed winget apps to current github repo
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$outfile = New-TemporaryFile

winget export $outfile --source winget
$j = Get-Content -Raw $outfile | ConvertFrom-Json
$j.Sources.Packages.PackageIdentifier | Sort-Object > $outfile

$winBin = Join-Path (Get-Bin) win
$wingetFile = Join-Path $winBin "wingetfile-$($ENV:COMPUTERNAME).txt"
Move-Item -Force $outfile $wingetFile
"Written to $wingetFile"
