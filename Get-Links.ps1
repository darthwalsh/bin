<#
.SYNOPSIS
Finds all symbolic links in a folder
.PARAMETER Path
Optionally, look in a different folder. Default to CWD.
.OUTPUTS
FileSystemInfo
#>

param(
    [string] $Path
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# TODO does this work on windows too?
Get-ChildItem $Path -Recurse -Force | Where-Object { $_.LinkType -ne $null }
