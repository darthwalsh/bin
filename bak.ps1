<#
.SYNOPSIS
Makes a copy of file in a temporary directory
.PARAMETER path
Path to backup
.OUTPUTS
Path to the backup file in both pwsh shorthand, and resolved path
TODO instead write to Temp:\bakup/log.txt instead of STDOUT?
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
if (Test-Path $bak) {
  $rand = ((65..90) + (97..122) | Get-Random -Count 8 | % { [char]$_ }) -join ''
  $bak = "$bak.$rand"
}
$bak

$info = Get-Item $path -Force
if ($info.Target) {
  Write-Host "Symlink to $($info.Target) -- making plaintext copy" -ForegroundColor Yellow
}

Copy-Item $path $bak
Convert-Path $bak
