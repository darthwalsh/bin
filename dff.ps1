<#
.SYNOPSIS
Diff output of two script blocks, files, or clipboard contents
.DESCRIPTION
like bash process substitution:
    diff <(echo "abc") <(echo "def")
Accepts script blocks, file paths, or FileInfo objects.
If one side is missing, the clipboard will be used.
If both are missing, the clipboard will be read twice (with a pause).
.PARAMETER Left
Script block, file path, or FileInfo for the left side of diff
.PARAMETER Right
Script block, file path, or FileInfo for the right side of diff
.PARAMETER Normalize
Script block to normalize the output of the script blocks. Needs to consume $input 
.PARAMETER Unified
Unified diff to remove context lines like: git diff -U0
.PARAMETER Gui
Use a GUI diff tool instead of git diff
.EXAMPLE
PS> dff { code -h } { cursor -h } { $input | tr -d '[:space:]' | fold -w 160 }
.EXAMPLE
PS> dff ./file1.txt ./file2.txt
#>

[CmdletBinding()]
param(
  $Left = $null,
  $Right = $null,
  [ScriptBlock] $Normalize = $null,
  [switch] $Unified = $false,
  [switch] $Gui = $false
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Resolve-ToTempFile($Side) {
  $tempFile = New-TemporaryFile
  if ($Side -is [ScriptBlock]) {
    & $Side > $tempFile
  }
  elseif ($Side -is [System.IO.FileInfo]) {
    Copy-Item $Side.FullName $tempFile
  }
  elseif ($Side) {
    Copy-Item $Side $tempFile  # errors if path doesn't exist
  }
  else {
    Get-Clipboard > $tempFile
  }
  return $tempFile
}

$leftPath = Resolve-ToTempFile $Left
if (-not $Left -and -not $Right) {
  Read-Host "Press Enter when right side is on clipboard"
}
$rightPath = Resolve-ToTempFile $Right

if ($Normalize) {
  $tmp = New-TemporaryFile # Can't read and write to the same file
  Write-Verbose "Left Before Norm: $(cat $leftPath | head -n 2)"
  cat $leftPath | & $Normalize > $tmp
  mv $tmp $leftPath
  Write-Verbose "Left After  Norm: $(cat $leftPath | head -n 2)"

  Write-Verbose "Right Before Norm: $(cat $rightPath | head -n 2)"
  cat $rightPath | & $Normalize > $tmp
  mv $tmp $rightPath
  Write-Verbose "Right After  Norm: $(cat $rightPath | head -n 2)"
}

$u0 = @()
if ($Unified) {
  $u0 += "-U0"
}

Write-Verbose "leftPath: $leftPath"
Write-Verbose "rightPath: $rightPath"

if ($Gui) {
  code --diff $leftPath $rightPath
}
else {
  try {
    git diff --no-index --word-diff=color --word-diff-regex=. @u0 $leftPath $rightPath
  }
  catch {
  }
}
