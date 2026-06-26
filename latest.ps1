<#
.SYNOPSIS
Gets latest files from input
.PARAMETER N
Number of files to return
.INPUTS
FileSystemInfos
.OUTPUTS
FileSystemInfos
#>

param(
  [int] $N = 1
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$Input | Sort-Object LastWriteTime -Descending | Select-Object -First $N
