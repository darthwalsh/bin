<#
.SYNOPSIS
Search for text in this bin folder
.DESCRIPTION
Args are same as Select-String: -Pattern -Context -Raw etc.
.PARAMETER History
Always search through git history
#>

param(
    [switch] $History=$false
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$results = Get-ChildItem -Recurse $PSScriptRoot | Select-String @args
$results

if (!$History -and @($results).Count) {
  return
}

Write-Host "--- git history ---" -ForegroundColor Yellow
# MAYBE figure out how to print the file name and line number on each line...
gb log --all --patch --unified=0 --color | Select-String @args
