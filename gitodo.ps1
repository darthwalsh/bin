<#
.SYNOPSIS
For a PR, find any TODO that has changed
#>

param (
    [Parameter()]
    $ref=""
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

if ($ref -eq "") {
    $ref = "origin/$(Get-GitDefaultBranch)"
}

git diff --unified=0 --color --no-prefix $ref | Select-String 'TODO|---'

foreach ($f in (git ls-files --others --exclude-standard)) {
  write-warning "Not checking $f as it is not in the index"

  # TODO try https://stackoverflow.com/a/857696/771768
  # git add --intent-to-add allows git diff to show changes
}
