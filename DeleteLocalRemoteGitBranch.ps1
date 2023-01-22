<#
.SYNOPSIS
Forcibly deletes branch locally and in default remote
#>

param(
    [Parameter(Mandatory=$true)]
    [string] $branch
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

if (git show-ref refs/heads/$branch) {
  git branch -D $branch
} else {
  Write-Warning "Local branch $branch not found"
}

if (git ls-remote --heads origin $branch) {
  git push --delete origin $branch
} else {
  Write-Warning "Remote branch $branch not found"
}

