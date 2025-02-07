<#
.SYNOPSIS
Replace a SYMlink with a regular file, optionally removing the link target
.DESCRIPTION
Undoes the effect of ln -s / symmove / New-Item -ItemType SymbolicLink
I would call it UNLINK but in Unix that means DELETE
#>

param(
    [Parameter(Mandatory=$true)]
    [string] $File,
    [switch] $RemoveLink=$false
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest


$info = Get-Item $File
if ($info.PSIsContainer) {
  throw "Unlinking directories is not supported!"
}
if ($info.LinkType -ne 'SymbolicLink') {
  throw "Unlinking plain files is not supported!"
}

$target = $info.Target
bak $target
Remove-Item $File

if ($RemoveLink) {
  Move-Item $target $File
} else {
  Copy-Item $target $File
}
