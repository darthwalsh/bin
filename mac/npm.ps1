<#
.SYNOPSIS
Reload nvm if needed
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

if (-not (Get-Command npm -CommandType Application -ErrorAction SilentlyContinue)) {
  [Console]::Error.WriteLine("(Reloading from nvm)")
  nvm current | Out-Null
}

$source = Get-Command npm -CommandType Application -ErrorAction SilentlyContinue
& $source @args
