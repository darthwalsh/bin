<#
.SYNOPSIS
For a PR, find any TODO that has been added/removed/modified
.PARAMETER pattern
The regex pattern to search for. Default is TODO/MAYBE/markdown-checkbox
ripgrep smart-case, where capital letters indicate case-sensitive
Uses lookbehind to match only in content, not filenames
.PARAMETER ref
The git ref to compare against. Default is origin/branch
#>

param (
    $pattern = "todo|maybe|- \[[^x-]\]",
    $ref=""
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

if ($ref -eq "") {
    $ref = "origin/$(Get-GitDefaultBranch)"
}

# Tracked changes
$PSNativeCommandUseErrorActionPreference = $false
$diffLines = git diff --unified=0 --color --no-prefix $ref | git-diff-lines 
$gitDiffLinePrefix = "^\S+ \S+ .*"
# \K resets the match position, so only the pattern is highlighted
$diffLines | rg -P "$gitDiffLinePrefix\K($pattern)" --colors match:fg:black --colors match:bg:white

# Untracked files
$untrackedFiles = git ls-files --others --exclude-standard
if ($untrackedFiles) {
  rg --no-heading --with-filename --line-number --colors "match:fg:green" --color=always $pattern $untrackedFiles
}

