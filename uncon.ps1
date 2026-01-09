<#
.SYNOPSIS
Fix Conflict file caused by onedrive sync
.DESCRIPTION
Resolve the conflict in the diff editor
Finds all patterns like"inbox/2026-01-06 (conflict 2026-01-06-12-25-25).md"
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

foreach ($file in Get-ChildItem -Path ~/notes/MyNotes -Filter "*(conflict *).md" -Recurse) {
  $orig = $File -replace ' \(conflict .*\)', ''
  if (!(Test-Path $orig)) {
    Write-Warning "Original file not found: $orig"
    continue
  }
  resolve-diff -Main $orig -ToDelete $File
}
