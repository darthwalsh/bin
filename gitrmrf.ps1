<#
.SYNOPSIS
GIT RM Force
.DESCRIPTION
Delete branches locally and remotely
.PARAMETER Branch
Branch name or glob
.EXAMPLE
PS> .\Script.ps1 foobar
#>

param(
    [string] $Branch
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

if (!$Branch) {
  $Branch = Get-GitBranch
}

$defBranch = Get-GitDefaultBranch
if ($Branch -eq $defBranch) {
  throw "Can't delete default branch $Branch"
}

if ($Branch -eq (Get-GitBranch)) {
  Write-Warning 'TODO avoid churn always fetch first, then dont pull at end: git fetch origin "$($defBranch):$defBranch"'
  git checkout $defBranch
}

function RemoteExists($b) {
  $eap = $ErrorActionPreference
  $ErrorActionPreference = 'SilentlyContinue'
  git show-branch "remotes/origin/$b" 2>&1 | out-null
  $branchExists = $?
  $ErrorActionPreference = $eap

  $branchExists
}

function DeleteBranch($b) {
  git branch -D $b

  if (RemoteExists $b) {
    git push --delete origin $b
  } else {
    "Remote branch $b didn't exist"
  }
}

git fetch --recurse-submodules=false

# Allow globs
$branches = git branch --list "$Branch" --format='%(refname:short)'
if (!$branches) {
  if (RemoteExists $Branch) {
    git push --delete origin $Branch
  } 
  "No branch matched $Branch ?" 
}

# For-Each is a bit slow... MAYBE run multiple on same line https://stackoverflow.com/a/63330836/771768
$branches | % { DeleteBranch $_ }

git pull origin "$($defBranch):$defBranch" --recurse-submodules=false
