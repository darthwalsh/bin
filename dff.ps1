<#
.SYNOPSIS
Diff output of two script blocks
.DESCRIPTION
like bash process substitution:
    diff <(echo "abc") <(echo "def")
If one script block is missing, the clipboard will be compared.
If both script blocks are missing, the clipboard will be read twice.
.PARAMETER Left
Script block to run on the left side of diff
.PARAMETER Right
Script block to run on the right side of diff
.EXAMPLE
PS> dff { code -h } { cursor -h }
#>

param(
    [ScriptBlock] $Left,
    [ScriptBlock] $Right
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest


$leftPath = New-TemporaryFile
$rightPath = New-TemporaryFile

if ($Left -and $Right) {
  & $Left > $leftPath
  & $Right > $rightPath
} elseif ($Left) {
  & $Left > $leftPath
  Get-Clipboard > $rightPath
} else {
  Get-Clipboard > $leftPath
  Read-Host "Press Enter when right side is on clipboard"
  Get-Clipboard > $rightPath
}


try {
  git diff --no-index --word-diff=color --word-diff-regex=. $leftPath $rightPath
}
catch {
}
