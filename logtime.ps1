<#
.SYNOPSIS
Script to loop over a log file, and replace timestamps with time diff in ms
#>

param(
    [Parameter(Mandatory=$true)]
    [string] $File
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$prev = $null
foreach ($line in Get-Content $File) {
  if ($line.StartsWith("[")) {
    $line = $line.TrimStart("[")
  }
  $stamp = [datetime]$line.SubString(0, 23)
  if ($prev -ne $null) { 
    $diff = $stamp - $prev
    $diff.TotalMilliSeconds.ToString().PadLeft(6) + "ms " + $prevLine.SubString(24, [System.Math]::Min(200, $prevLine.Length) - 24)
  }
  $prevLine = $line
  $prev = $stamp
}

