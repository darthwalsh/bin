<#
.SYNOPSIS
Resolve two files via diff so that all content ends up in $Main and $ToDelete is deleted.
.DESCRIPTION
Opens a GUI diff between the two files. You should make EITHER or BOTH sides the final content.
After GUI  closes:
- If both files are non-empty and different, abort with an error.
- If $Main is empty and $ToDelete has content, copy content from $ToDelete to $Main.
- Finally, delete $ToDelete.
.PARAMETER Main
The file that will contain the final content after resolution.
.PARAMETER ToDelete
The file that will be deleted after successful resolution.
.EXAMPLE
resolve_diff.ps1 -Main ~/.gitconfig -ToDelete ~/Downloads/.gitconfig
#>

param(
  [Parameter(Mandatory=$true)]
  [string] $Main,
  [Parameter(Mandatory=$true)]
  [string] $ToDelete
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$mainPath = (Resolve-Path $Main).Path
$toDeletePath = (Resolve-Path $ToDelete).Path
if ($mainPath -eq $toDeletePath) {
  throw "-Main and -ToDelete must be different paths"
}

function Ensure-PlainFile($path) {
  if (!(Test-Path $path)) {
    throw "Not found: $path"
  }
  $item = Get-Item $path -Force
  if ($item.PSIsContainer) {
    throw "Directories are not supported: $path"
  }
  $hasLinkProp = $item.PSObject.Properties.Match('LinkType').Count -gt 0
  if ($hasLinkProp -and $item.LinkType -ne $null) {
    throw "Links are not supported: $path"
  }
}

Ensure-PlainFile $mainPath
Ensure-PlainFile $toDeletePath

bak $mainPath
bak $toDeletePath

function size($path) {
  if (Test-Path $path) {
    (Get-Item $path -Force).Length
  }
  else {
    0
  }
}
# If both have content, open diff to let user decide
if (size $mainPath -and size $toDeletePath) {
  Write-Host "Opening diff: Main=$mainPath ToDelete=$toDeletePath" -ForegroundColor Yellow
  Write-Host "Make ONE side represent the final content. Both non-empty and different will abort." -ForegroundColor Yellow
  code --wait --diff $mainPath $toDeletePath
}

$mainSize = size $mainPath
$delSize = size $toDeletePath

# If both are non-empty, they must be identical
if ($mainSize -and $delSize) {
  $mainHash = (Get-FileHash $mainPath).Hash
  $delHash = (Get-FileHash $toDeletePath).Hash
  if ($mainHash -ne $delHash) {
    throw "Both files remain non-empty and differ. Empty one side or make them identical."
  }
}

if (!$mainSize -and $delSize) {
  # Keep ToDelete's content
  Copy-Item $toDeletePath $mainPath -Force
}

Remove-Item $toDeletePath -Force

Write-Output $mainPath
