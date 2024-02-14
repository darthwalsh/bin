<#
.SYNOPSIS
Copies files from one location to OneDrive
#>

param(
    [Parameter(Mandatory=$true)]
    [string] $File
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

foreach ($line in Get-Content $File) {
  if (-not $line) { continue }
  $dest = Join-Path ~/OneDrive/TODO/HardDiskCopy $line
  "Copying to $dest"
  New-Item -ItemType Directory -Path (Split-Path $dest) -Force | Out-Null
  Copy-Item $line $dest
}
