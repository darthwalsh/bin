<#
.SYNOPSIS
Temp script for rescuing file from old drive user folder, copying to same location in new user folder
#>

[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [Parameter(Mandatory=$true)]
    [string] $File
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

function bak($path) {
  if (![System.IO.Path]::IsPathRooted($path)) { throw "Not absolute: $path" }
  $bakDir = 'Temp:\migrate_dotfiles'
  mkdir $bakDir -Force | Out-Null

  $normalized = $path -replace '_', '__' -replace '[^\w]', '_'
  $bak = Join-Path $bakDir "$normalized.bak.$([System.IO.Path]::GetExtension($path))"
  Copy-Item $path $bak
  $bak
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


$dotFilesFile = Move-Item $old $dotFiles -PassThru
New-Item -ItemType SymbolicLink -Path $new -Value $dotFilesFile
$new >> $readme
