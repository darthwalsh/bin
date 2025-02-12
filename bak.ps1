<#
.SYNOPSIS
Makes a copy of file in a temporary directory
.PARAMETER path
Path to backup
#>

param(
    [Parameter(Mandatory=$true)]
    [string] $path
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$bakDir = 'Temp:\bakup'
New-Item -ItemType Directory $bakDir -Force | Out-Null

$normalized = (Resolve-Path $path) -replace '_', '__' -replace '[^\w]', '_'
$bak = Join-Path $bakDir "$normalized.bak"
$ext = [System.IO.Path]::GetExtension($path)
if ($ext) {
  $bak = "$bak.$ext"
}
$bak

$info = Get-Item $path
if ($info.Target) {
  Write-Host "Symlink to $($info.Target) -- making plaintext copy" -ForegroundColor Yellow
}

Copy-Item $path $bak
Convert-Path $bak
