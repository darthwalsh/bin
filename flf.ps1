<#
.SYNOPSIS
Force LF endings
.PARAMETER File
The file
#>

param(
  [Parameter(Mandatory = $true)]
  [string] $File
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

((Get-Content $File) -join "`n") + "`n" | Set-Content -NoNewline $File
