<#
.SYNOPSIS
Save WIP branch to Git.
.DESCRIPTION
Creates new local and remote branch.
Commits all changes to that branch and switches back.
#>

param(
    [Parameter(Mandatory=$true)]
    [string] $BranchName
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$currentBranch = git rev-parse --abbrev-ref HEAD

git checkout -b $BranchName
git add -A
git commit -m "WIP"

git push -u origin $BranchName

git checkout $currentBranch

"Changes saved to branch '$BranchName' and pushed to remote. Returned to '$currentBranch'."


