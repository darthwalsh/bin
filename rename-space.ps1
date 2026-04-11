<#
.SYNOPSIS
Rename a file to replace spaces with underscores
.PARAMETER File
File to rename
#>

using namespace System.IO

param(
    [Parameter(Mandatory=$true)]
    [FileInfo] $File
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$fixedName = $File.Name.Replace(' ', '_')
if ($fixedName -eq $File.Name) {
    Write-Verbose "No spaces found in $($File.Name)"
    return
}

$fixedPath = Join-Path $File.DirectoryName $fixedName
Rename-Item $File.FullName $fixedPath
$fixedPath
