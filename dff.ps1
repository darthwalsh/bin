<#
.SYNOPSIS
Diff output of two script blocks
.DESCRIPTION
like bash process substitution:
    diff <(echo "abc") <(echo "def")
.PARAMETER Left
Script block to run on the left side of diff
.PARAMETER Right
Script block to run on the right side of diff
.EXAMPLE
PS> dff { code -h } { cursor -h }
#>

param(
    [Parameter(Mandatory=$true)]
    [ScriptBlock] $Left,
    [Parameter(Mandatory=$true)]
    [ScriptBlock] $Right
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest


$leftPath = New-TemporaryFile
$rightPath = New-TemporaryFile

& $Left > $leftPath
& $Right > $rightPath

try {
  git diff --no-index --word-diff=color --word-diff-regex=. $leftPath $rightPath
}
catch {
}
