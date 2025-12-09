<#
.SYNOPSIS
Browse github in browser in the current branch (or default if doesn't exist)
.PARAMETER Permalink
Use the commit/sha_hash permalink instead of the branch. (Doesn't work for non-PassThru)
.PARAMETER PassThru
Don't open browser, just print the URL
#>

param(
  [switch] $Permalink = $false,
  [switch] $PassThru = $false
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$branch = Get-GitBranch

if ($branch -eq (Get-GitDefaultBranch)) {
  $arg = @()
} else {
  try {
    git show-branch "remotes/origin/$branch" 2>&1 | out-null
    $arg = @(if ($Permalink) {
      "--commit"
      # Don't include --branch because it's already implied by --commit
    } else {
      "--branch"
      $branch
    })
  } catch {
    $arg = @()
  }
}

if ($PassThru) {
  $arg += @("--no-browser")
}
$output = gh browse @arg
if ($Permalink) {
  $output = $output.Replace("/tree/", "/commit/")
}
$output
