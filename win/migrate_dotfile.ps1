<#
.SYNOPSIS
Temp script for rescuing file from old drive user folder.
.DESCRIPTION
Copies from K:\Users\you to C:\Users\you, like mac/migrate_dotfile.ps1
Also sets up a symlink into git repo dotfiles for later
Useful even if you don't indent to set up a dotfile, but just want to copy parts of your old local config file onto new drive.
.PARAMETER File
The file to copy from old drive to new drive.
Should resolve to old home folder.
.PARAMETER FullPath
Instead of using just the file name inside dotfiles, use $File
.EXAMPLE
migrate_dotfile.ps1 K:\Users\cwalsh\.gitconfig -WhatIf
#>

[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [Parameter(Mandatory=$true)]
    [string] $File,
    [switch] $FullPath=$null
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$oldHome = 'K:\Users\cwalsh' # Set this to your old hard drive ~
$newHome = "$(Resolve-Path ~)"

$dotFiles = Join-Path (Get-Bin) dotfiles
$readme = Join-Path $dotFiles 'README.md'

$old = Resolve-Path $File
if (!$old.Path.StartsWith($oldHome)) {
  throw "Not in old home: $old"
}
$oldItem = Get-Item $old
if ($oldItem.PSIsContainer) {
  throw "Linking directories is not supported!"
}
if ($oldItem.LinkType -ne $null) {
  throw "Linking links is not supported!"
}

function size($path) {
  if (Test-Path $path) {
    (Get-Item $path).Length
  } else {
    0
  }
}

$new = $old.Path.Replace($oldHome, $newHome)
if (size $new) {
  bak $old
  bak $new

  Write-Host "$new already exists, opening diff view and edit one down to nothing" -ForegroundColor Yellow
  Write-Host "Merge contents to one file, leaving other empty" -ForegroundColor Yellow
  code --wait --diff $new $old
  if (size $new) {
    if (size $old) {
      if ($(Get-FileHash $old).Hash -eq $(Get-FileHash $new).Hash) {
        throw "TODO should be OK to combine now"
      }
      throw "Should edit one to file: $new"
    }
    Copy-Item $new $old -Force
  }
}
if (Test-Path $new) {
  if (size $new) {
    throw "Should be empty: $new"
  }
  Remove-Item $new
}

$dotFilesFile = if ($FullPath) {
  $File
} else {
  $oldItem.Name
}
$dotFilesFile = Join-Path $dotFiles $dotFilesFile

$destinationDir = Split-Path $dotFilesFile -Parent
mkdir $destinationDir -Force | Out-Null

# MAYBE could call add_dotfile instead
Move-Item $old $dotFilesFile
if ($WhatIfPreference) {
  "What if: Performing the operation $new -> $dotFilesFile"
} else {
  New-Item -ItemType SymbolicLink -Path $new -Value $dotFilesFile
}
$new >> $readme
