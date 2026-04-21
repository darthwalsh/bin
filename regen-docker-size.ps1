<#
.SYNOPSIS
Reads docker.images.md, measures each image size, and reprints those lines with updated MB
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest


$File = (Join-Path $PSScriptRoot 'apps/docker.images.md')

function Get-ImageSizeMB([string]$Image) {
  if ($Image -eq 'scratch') { return 0 }
  docker pull --quiet $Image 2>&1 | Out-Null
  $bytes = docker image inspect $Image --format '{{.Size}}'
  return [math]::Floor([long]$bytes / 1MB)
}

Get-Content $File | Where-Object { $_ -match '^\| `FROM ' } | ForEach-Object {
  if ($_ -match '`FROM ([^`]+)`') {
    $mb = Get-ImageSizeMB $Matches[1]
    [PSCustomObject]@{ MB = $mb; Line = $_ -replace '\d+ MB', "$mb MB" }
  }
} | Sort-Object MB | Select-Object -ExpandProperty Line
