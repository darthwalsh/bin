<#
.SYNOPSIS
Script to loop over a log file, and replace timestamps with time diff in ms
#>

param(
    [Parameter(Mandatory=$true)]
    [string] $File,
    [int] $MinTimeMS = -1
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$prev = $null
foreach ($line in Get-Content $File) {
  if ($line.StartsWith("[")) {
    $line = $line.TrimStart("[")
  }
  try {
    $stamp = [datetime]$line.SubString(0, 23)
  } catch {
    Write-Warning "Failed to parse timestamp: $_"
    Write-Warning "    Line: $line"
    continue
  }
  if ($prev -ne $null) { 
    $diff = $stamp - $prev
    if ($MinTimeMS -eq -1 -or $diff.TotalMilliseconds -ge $MinTimeMS) {
      $diff.TotalMilliSeconds.ToString().PadLeft(6) + "ms " + $prevLine.SubString(24, [System.Math]::Min(200, $prevLine.Length) - 24)
    }
  }
  $prevLine = $line
  $prev = $stamp
}

