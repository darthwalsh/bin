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
.PARAMETER Normalize
Script block to normalize the output of the script blocks
.PARAMETER Unified
Unified diff to remove context lines like: git diff -U0
.EXAMPLE
PS> dff { code -h } { cursor -h } { $input | tr -d '[:space:]' | fold -w 160 }
#>

param(
    [ScriptBlock] $Left,
    [ScriptBlock] $Right,
    [ScriptBlock] $Normalize=$null,
    [switch] $Unified=$false
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest


$leftPath = New-TemporaryFile
$rightPath = New-TemporaryFile

# TODO allow left and right to be path as string or fileinfo objects
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

if ($Normalize) {
  $tmp = New-TemporaryFile # Can't read and write to the same file
  cat $leftPath | & $Normalize > $tmp
  mv $tmp $leftPath


  cat $rightPath | & $Normalize > $tmp
  mv $tmp $rightPath
}

$u0 = @()
if ($Unified) {
  $u0 += "-U0"
}

try {
  git diff --no-index --word-diff=color --word-diff-regex=. @u0 $leftPath $rightPath
}
catch {
}
