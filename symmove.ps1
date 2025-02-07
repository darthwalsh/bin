<#
.SYNOPSIS
MOVE a file/folder to a new location, and replace with SYMlink
#>

param(
  [Parameter(Mandatory=$true)]
  [string] $Item,
  [Parameter(Mandatory=$true)]
  [string] $TargetDir,
  $OverrideName=$null
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

mkdir $TargetDir -Force | Out-Null
bak $item

$moved = Join-Path $TargetDir ($OverrideName ?? (Split-Path $Item -Leaf))
Move-Item -Path $Item -Destination $moved
New-Item -ItemType SymbolicLink -Path $Item -Target (Convert-Path $moved)
