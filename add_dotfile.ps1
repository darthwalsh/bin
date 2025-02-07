<#
.SYNOPSIS
MOVE a file/folder to dotfiles
.DESCRIPTION
Related to migrate_dotfile
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

symmove $File $dotFiles -OverrideName $OverrideName

$dbEntry = Convert-Path $File
if ($OverrideName) {
    $dbEntry = "$dbEntry -> $OverrideName"
}
$dbEntry >> $readme
