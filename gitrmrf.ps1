<#
.SYNOPSIS
Runs a command
.DESCRIPTION
More description
.PARAMETER File
Param 1
.INPUTS
Pipe something?
.OUTPUTS
Prints something fancy?
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

if ($Branch -eq (Get-GitDefaultBranch)) {
  throw "Can't delete default branch $Branch"
}

if ($Branch -eq (Get-GitBranch)) {
  git checkout (Get-GitDefaultBranch)
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

# Allow globs
$branches = git branch --list "$Branch" --format='%(refname:short)'
if (!$branches) {
  if (RemoteExists $Branch) {
    git push --delete origin $Branch
  } 
  "No branch matched $Branch ?" 
}

# For-Each is a bit slow; can run multiple on same line https://stackoverflow.com/a/63330836/771768
$branches | % { DeleteBranch $_ }

git pull
