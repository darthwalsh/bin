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

function RemoteExists($b) {
  $eap = $ErrorActionPreference
  $ErrorActionPreference = 'SilentlyContinue'
  git show-branch "remotes/origin/$b" 2>&1 | out-null
  $branchExists = $?
  $ErrorActionPreference = $eap

  $branchExists
}

function DeleteBranch($b) {
  if ($b -eq $defBranch) {
    throw "Can't delete default branch $b"
  }
  if ($b -eq (Get-GitBranch)) {
    git fetch $(Get-GitDefaultBranchRemote) "$($defBranch):$defBranch" --recurse-submodules=false --quiet
    git checkout $defBranch
  }

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
