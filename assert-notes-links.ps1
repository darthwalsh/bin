<#
.SYNOPSIS
Checks the ~/notes directory for unexpected files
#>


$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# Anything in ~/notes should probably be a symlink
# Users/ is owned by root, otherwise Obsidian is happy to create Users/walshca/...
$expected = "
Users
notes.code-workspace
".Trim().Split("`n")

$nonLinks = Get-ChildItem ~/notes | Where-Object LinkTarget -eq $null
$nonLinks | ForEach-Object {
  if ($expected -notcontains $_.Name) {
    Write-Warning "$_ is a real file not a symlink"
    Get-ChildItem -Recurse $_
    Write-Host "`nIf useless, consider running:`n  $(ee rm -rf $_)" -ForegroundColor Magenta
  }
}

