<#
.SYNOPSIS
Find branched AI discussions
.DESCRIPTION
Based on the first line of first chat, line 9
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$files = fd --extension md
$grouped = $files | ForEach-Object {
  $file = $_
  $line9 = (Get-Content -LiteralPath $file -TotalCount 9)[8]
  [PSCustomObject]@{ File = $file; Line9 = $line9 }
} | Group-Object -Property Line9 | Where-Object { $_.Count -gt 1 }

foreach ($group in $grouped) {
  $group.Group.File
  ""
}
