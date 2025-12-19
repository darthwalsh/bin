<#
.SYNOPSIS
Gets latest file in ~/Downloads
.PARAMETER Open
Open the latest file in IDE
#>

param(
  [switch] $Open = $false
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$latest = gci ~/Downloads | Sort-Object LastWriteTime -Descending | Select-Object -First 1 | fn
if ($Open) {
  code $latest
} else {
  $latest
}
