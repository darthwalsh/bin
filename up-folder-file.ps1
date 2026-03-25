<#
.SYNOPSIS
Given a folder that contains any single file, convert foo/ to file with that contents
.Description
If you accidentally create a folder with a single file in it, this will convert it to a file with that contents.
Fails if the folder doesn't contain exactly one file.
.PARAMETER Folder
Folder to convert to a file
#>

param(
    [Parameter(Mandatory=$true)]
    [string] $Folder
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$Folder = $Folder.TrimEnd('/\')

if (-not (Test-Path $Folder -PathType Container)) {
    throw "Not a directory: $Folder"
}

$children = @(Get-ChildItem -LiteralPath $Folder)
if ($children.Count -ne 1) {
    throw "Expected exactly 1 file in '$Folder', found $($children.Count)"
}

$innerFile = $children[0]
if ($innerFile.PSIsContainer) {
    throw "The single item inside '$Folder' is itself a directory: $($innerFile.Name)"
}

bak $innerFile | Out-Null

$tmp = Join-Path (Convert-Path Temp:\) $innerFile.Name
Move-Item -LiteralPath $innerFile.FullName -Destination $tmp
Remove-Item -LiteralPath $Folder
Move-Item -LiteralPath $tmp -Destination $Folder

"Converted folder '$Folder' -> file (was $($innerFile.Name))"
