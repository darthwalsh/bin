<#
.SYNOPSIS
Opens the most recently changed markdown "#ai-slop"
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

throw "TODO not sure about deslop.ps1, but not a good use of time to just work on the latest one!"

$notes = Join-Path (Get-Bin) apps/*.md
$aiSlop = Get-ChildItem $notes | 
  Where-Object { Select-String '#ai-slop' $_ } |
  Sort-Object LastWriteTime -Descending | 
  Select-Object -First 1

if ($aiSlop) {
  "Opening $aiSlop -- remove #ai-slop"
  throw "TODO use obsidian CLI to open"
  open $aiSlop
} else {
  echo "No slop to be found!"
}
