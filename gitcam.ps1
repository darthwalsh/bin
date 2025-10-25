<#
.SYNOPSIS
git amend commit changed files into recent commit
.PARAMETER ForcePush
Force push to remote
#.PARAMATER Fixup
TODO add parameter to create `git commit --fixup` instead of amend
And then run `git rebase --autosquash` (non-interactive, rebasing back far enough)
#>

param(
  [switch]$Edit,
  [switch]$ForcePush
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$editArg = if ($Edit) { "--edit" } else { "--no-edit" }

$status = Get-GitStatus
$allArg = @()
if ($status.HasIndex) {
  Write-Warning "Only staged files will be committed: $($status.Index -join " ")"
}
elseif ($status.HasUntracked) {
  git status --porcelain | sls '^\?\?'
  throw "Untracked files!"
} else {
  Write-Verbose "Committing all files"
  $allArg += "--all"
}

git commit --amend $editArg @allArg

if ($ForcePush) {
  git push --force-with-lease --force-if-includes
}
