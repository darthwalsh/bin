<#
.SYNOPSIS
Activate venv
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$envDir = gci -Directory *env*

if (@($envDir).Count -ne 1) { throw $envDir.Name }

$activate = @(
  (Join-Path $envDir Scripts Activate.ps1),
  (Join-Path $envDir bin Activate.ps1)
) | ? { Test-Path $_ }

if (@($activate).Length -ne 1) { throw $activate.Name }

. $activate -prompt 'v'
