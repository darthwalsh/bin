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

git diff --unified=0 --color --no-prefix $ref | Select-String 'TODO|MAYBE|\+\+\+'
# Would be nice to add clickable line numbers, but it's non-trivial: https://stackoverflow.com/q/24455377/771768

foreach ($f in (git ls-files --others --exclude-standard)) {
  "ADD $f" | Select-String '^ADD'
  Select-String 'TODO|MAYBE' $f

  # TODO try https://stackoverflow.com/a/857696/771768
  # git add --intent-to-add allows git diff to show changes
}

