<#
.SYNOPSIS
For a PR, find any TODO that has been added/removed/modified
.PARAMETER pattern
The regex pattern to search for. Default is /TODO|MAYBE/
.PARAMETER ref
The git ref to compare against. Default is the default branch.
#>

param (
    $pattern = "TODO|MAYBE",
    $ref=""
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

if ($ref -eq "") {
    $ref = "origin/$(Get-GitDefaultBranch)"
}

git diff --unified=0 --color --no-prefix $ref | Select-String "$pattern|\+\+\+"
# Would be nice to add clickable line numbers, but it's non-trivial: https://stackoverflow.com/q/24455377/771768

foreach ($f in (git ls-files --others --exclude-standard)) {
  "ADD $f" | Select-String '^ADD'
  Select-String $pattern $f

  # TODO try https://stackoverflow.com/a/857696/771768
  # git add --intent-to-add allows git diff to show changes
}

