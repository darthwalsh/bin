<#
.SYNOPSIS
Opens the most recently changed markdown "#ai-slop"
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$notes = Join-Path (Get-Bin) apps/*.md
$aiSlop = Get-ChildItem $notes | 
  Where-Object { Select-String '#ai-slop' $_ } |
  Sort-Object LastWriteTime -Descending | 
  Select-Object -First 1

if ($aiSlop) {
  "Opening $aiSlop -- remove #ai-slop"
  open $aiSlop
} else {
  echo "No slop to be found!"
}
