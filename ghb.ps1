<#
.SYNOPSIS
Browse github in browser in the current branch (or default if doesn't exist)
.PARAMETER PassThru
Don't open browser, just print the URL
#>

param(
  [switch] $PassThru = $false
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$branch = Get-GitBranch

if ($branch -eq (Get-GitDefaultBranch)) {
  $args = @()
} else {
  try {
    git show-branch "remotes/origin/$branch" 2>&1 | out-null
    $args = @("-b", $branch)
  } catch {
    $args = @()
  }
}

if ($PassThru) {
  $args += @("--no-browser")
}

gh browse @args
