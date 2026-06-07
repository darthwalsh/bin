<#
.SYNOPSIS
Given file names with timestamp or ISO ymd hms, rename it to YYYY-MM-DD.ext
.PARAMETER File
i.e.
1778776206474.m4a
2026-05-09 11.04.49.m4a
.EXAMPLE
PS> rename-ymd 17*
#>

using namespace System.IO

[CmdletBinding(SupportsShouldProcess=$true)]
param(
  [Parameter(Mandatory = $true)]
  [string] $File
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function RenameOne([FileInfo] $item) {
  $baseName = $item.BaseName

  $date = if ($baseName -match '^\d{13}$') {
    [DateTimeOffset]::FromUnixTimeMilliseconds([long]$baseName).LocalDateTime.Date
  }
  elseif ($baseName -match '^\d{10}$') {
    [DateTimeOffset]::FromUnixTimeSeconds([long]$baseName).LocalDateTime.Date
  }
  elseif ($baseName -match '^(\d{4}-\d{2}-\d{2})') {
    [datetime]::ParseExact($Matches[1], 'yyyy-MM-dd', $null)
  }
  else {
    throw "Cannot parse date from filename: $baseName"
  }

  $newName = $date.ToString('yyyy-MM-dd') + $item.Extension
  if ($newName -eq $item.Name) {
    Write-Verbose "Already named $newName"
    return
  }

  $newPath = Join-Path $item.DirectoryName $newName
  if (Test-Path -LiteralPath $newPath) {
    throw "Target already exists: $newPath"
  }

  if ($PSCmdlet.ShouldProcess($item.Name, "Rename to $newName")) {
    Rename-Item -LiteralPath $item.FullName -NewName $newName
    $item.DirectoryName + [IO.Path]::DirectorySeparatorChar + $newName
  }
}

foreach ($item in Get-Item $File) {
  RenameOne $item
}
