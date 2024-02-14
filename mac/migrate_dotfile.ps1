<#
.SYNOPSIS
Script for rescuing file from old user folder, copying to same location in new user folder

Writes a note in dotfiles.md in the notes inbox
#>

param(
    [Parameter(Mandatory=$true)]
    [string] $File
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

if ($File.StartsWith("./")) {
  $File = $File.Substring(2)
}

$oldHome = '/Users/walshca_1'
$oldFile = join-path $oldHome $File
if (!(Test-Path $oldFile)) {
  throw "Not found: $oldFile"
}
#recurse on directories
if (Test-Path $oldFile -PathType Container) {
  foreach ($f in (Get-ChildItem $oldFile)) {
    ff $f.FullName.Substring(1+$oldHome.Length)
  }
  return
}

$newHome = '/Users/walshca'
$newFile = join-path $newHome $File
if (Test-Path $newFile) {
  Write-Warning "$newFile already exists"
  Get-Content $newFile
  $response = Read-Host "Overwrite $newFile ? (y/n)"
  if ($response -ne "y") {
    throw "Aborted"
  }
}

if (!(Test-Path (Split-Path $newFile))) {
  mkdir (Split-Path $newFile)
}

Copy-Item $oldFile $newFile
$File >> (join-path $newHome notes/MyNotes/inbox/dotfiles.md)
