<#
.SYNOPSIS
Splits $ENV:PATH into separate lines
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$ENV:Path -split [IO.Path]::PathSeparator | % { 
  if (Test-Path $_) {
    $_
  } else {
    Write-Host $_ -ForegroundColor Yellow
  }
}
