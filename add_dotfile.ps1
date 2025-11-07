<#
.SYNOPSIS
MOVE a file/folder to dotfiles
.DESCRIPTION
Related to migrate_dotfile. Handles existing targets with explicit merge semantics using resolve-diff.
Notes:
- Directory merges are not automatic; resolve directories externally or handle file-by-file.
#>

param(
    [Parameter(Mandatory=$true)]
    [string] $File,
    $OverrideName=$null
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$dotFiles = Join-Path (Get-Bin) dotfiles
$readme = Join-Path $dotFiles 'README.md'

$destPath = Join-Path $dotFiles ($OverrideName ?? (Split-Path $File -Leaf))
if (Test-Path $destPath) {
    # Destination exists in dotfiles: consolidate content into dest and 
    resolve-diff -Main $destPath -ToDelete $File
    New-Item -ItemType SymbolicLink -Path $File -Value $destPath | Out-Null
} else {
    symmove $File $dotFiles -OverrideName $OverrideName
}

$dbEntry = Convert-Path $File
if ($OverrideName) {
    $dbEntry = "$dbEntry -> $OverrideName"
}
$dbEntry >> $readme
