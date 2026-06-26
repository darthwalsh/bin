<#
.SYNOPSIS
Gets latest file in ~/Downloads
.PARAMETER N
Number of files to return
.PARAMETER Open
Open the latest file in IDE
#>

param(
  [int] $N = 1,
  [switch] $Open = $false
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$latest = gci ~/Downloads | latest $N | fn
if ($Open) {
  code $latest
} else {
  $latest
}
