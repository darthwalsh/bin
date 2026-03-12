<#
.SYNOPSIS
Git fixup commit to a previous commit, selected interactively via fzf.
.DESCRIPTION
Stages all changes, lets you pick a past commit via fzf, then runs:
  git commit --fixup <sha>
  git rebase --autosquash <sha>~1
.LINK
https://stackoverflow.com/questions/3103589/how-can-i-easily-fixup-a-past-commit
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$selected = git log --oneline --color=always | fzf --ansi --no-sort --prompt="Fixup into> "
if (-not $selected) {
    Write-Warning "No commit selected, aborting."
    exit 0
}

# First token is the short SHA; resolve to full SHA for safety
$shortSha = ($selected -split '\s+')[0]
$sha = git rev-parse $shortSha

$status = Get-GitStatus
if ($status.HasIndex) {
    Write-Warning "Only staged files will be committed: $($status.Index -join ' ')"
} elseif ($status.HasUntracked) {
    git status --porcelain | sls '^\?\?'
    throw "Untracked files! Stage or stash them first."
} else {
    # Nothing staged, no untracked — stage all tracked changes
    git add --update
}

"Fixing up into $sha ($($selected.Trim()))"
git commit --fixup $sha
git rebase --autosquash "${sha}~1"
