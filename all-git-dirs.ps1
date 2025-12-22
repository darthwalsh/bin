<#
.SYNOPSIS
Get all git projects that I might want to automate
.DESCRIPTION
Override in other projects as needed.
.OUTPUTS
FileSystemInfo
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$dirs = Get-ChildItem ~/code -Directory
foreach ($dir in $dirs) {
  if (Test-Path (Join-Path $dir.FullName '.git')) {
    $dir
  }
}
