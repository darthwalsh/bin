<#
.SYNOPSIS
Forcibly deletes branch locally and in default remote
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory=$true)]
    [string] $branch,
    [switch] $ignoreRemoteNotFound
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

try {
  if ($PSCmdlet.ShouldProcess($branch, "Delete local branch")) {
    git branch -D $branch
  }
} catch {
  # git will print warning on errors like not found
}

if (git ls-remote --heads origin $branch) {
  if ($PSCmdlet.ShouldProcess($branch, "Delete remote branch")) {
    git push --delete origin $branch
  }
} else {
  if (!$ignoreRemoteNotFound) {
    Write-Warning "Remote branch $branch not found"
  }
}

