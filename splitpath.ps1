<#
.SYNOPSIS
Splits $ENV:PATH into separate lines
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest


$seen = @{}
$ENV:PATH -split [IO.Path]::PathSeparator | % { 
  if (Test-Path $_) {
    if ($seen.ContainsKey($_)) { 
      Write-Host $_ -ForegroundColor Magenta
    } else {
      $seen[$_] = $true
      $_
    }
  } else {
    Write-Host $_ -ForegroundColor Yellow
  }
}
