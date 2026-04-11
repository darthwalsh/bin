<#
.SYNOPSIS
Convert git diff to grep-like format with clickable file:line-numbers
.DESCRIPTION
Alternative: `delta --line-numbers` reconstructs line numbers from hunks and renders
them inline with color. Pro: battle-tested, handles renames/binary/submodules, looks great in a TTY.
Con: delta is a *pager* — it consumes stdout and renders to the terminal, so `git diff | delta | rg pattern`
breaks (delta renders ANSI tables, not grep-friendly text). This script keeps output as plain piped text,
so `git diff ... | git-diff-lines | rg TODO` works as expected.
#ai-slop
.INPUTS
pipe git diff to stdin
.OUTPUTS
Keeps git diff format, with space after +- marker so link is clickable
.EXAMPLE
PS> git show HEAD | git-diff-lines
PS> git diff --unified=0 --color --no-prefix origin/main | git-diff-lines
#>

[CmdletBinding()]
param(
    [Parameter(ValueFromPipeline)]
    [string]$Line
)

begin {
    $script:ErrorActionPreference = "Stop"
    Set-StrictMode -Version Latest

    $script:inDiff = $false
    $script:file = ""
    $script:oldLine = 0
    $script:newLine = 0
}

process {
    $OriginalLine = $Line
    # Strip ANSI escape codes for regex matching only
    $Plain = $Line -replace '\x1b\[[0-9;]*m', ''
    
    # Handle both `diff --git a/file b/file` and `diff --git file file` (--no-prefix)
    if ($Plain -match '^diff --git .*\s(?:b/)?(.+)$') {
        $script:inDiff = $true
        $script:file = $Matches[1]
    }
    elseif (-not $script:inDiff) {
        # Skip commit message lines before first diff
    }
    elseif ($Plain -match '^@@ -(\d+)(?:,\d+)? \+(\d+)') {
        $script:oldLine = [int]$Matches[1]
        $script:newLine = [int]$Matches[2]
    }
    elseif ($Plain -match '^\+' -and $Plain -notmatch '^\+\+\+') {
        # Capture leading ANSI codes and extract content after the + prefix
        $ColorPrefix = if ($OriginalLine -match '^(\x1b\[[0-9;]*m)+') { $Matches[0] } else { '' }
        $Content = $OriginalLine -replace '^(\x1b\[[0-9;]*m)*\+', ''
        "$ColorPrefix+ $($script:file):$($script:newLine) $Content"
        $script:newLine++
    }
    elseif ($Plain -match '^-' -and $Plain -notmatch '^---') {
        $ColorPrefix = if ($OriginalLine -match '^(\x1b\[[0-9;]*m)+') { $Matches[0] } else { '' }
        $Content = $OriginalLine -replace '^(\x1b\[[0-9;]*m)*-', ''
        "$ColorPrefix- $($script:file):$($script:oldLine) $Content"
        $script:oldLine++
    }
    elseif ($Plain -match '^ ') {
        $Content = $OriginalLine -replace '^(\x1b\[[0-9;]*m)* ', ''
        "  $($script:file):$($script:newLine) $Content"
        $script:oldLine++
        $script:newLine++
    }
    Write-Verbose "$Plain : $script:inDiff : $script:file : $script:oldLine : $script:newLine"
}
