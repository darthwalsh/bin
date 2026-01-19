<#
.SYNOPSIS
Remove empty markdown notes, then empty directories
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Remove-WithConfirmation($Paths) {
  if (-not $Paths) { return }
    
  $Paths | Remove-Item -WhatIf
  Write-Host "Ok to remove? [y/N] " -ForegroundColor Red -NoNewline
  if ((Read-Host) -ne 'y') {
    Write-Warning "Aborting" 
    Exit 1
  }
  $Paths | Remove-Item
}

# Can't get Get-ChildItem to recurse without diving into git-ignored 
$empty = fd --follow --extension md --type empty --base-directory ~/notes | `
    Where-Object { $_ -notmatch 'TechJunks' } | `
    ForEach-Object { Join-Path ~/notes $_ }
Remove-WithConfirmation $empty

$emptyDirs = fd --follow --type empty --type directory --base-directory ~/notes | ForEach-Object { Join-Path ~/notes $_ }
Remove-WithConfirmation $emptyDirs
