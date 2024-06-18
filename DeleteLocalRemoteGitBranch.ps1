<#
.SYNOPSIS
Forcibly deletes branch locally and in default remote
#>

param(
    [Parameter(Mandatory=$true)]
    [string] $branch,
    [switch] $ignoreRemoteNotFound
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

try {
  git branch -D $branch
} catch {
  # git will print warning on errors like not found
}

if (git ls-remote --heads origin $branch) {
  git push --delete origin $branch
} else {
  if (!$ignoreRemoteNotFound) {
    Write-Warning "Remote branch $branch not found"
  }
}

