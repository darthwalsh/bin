<#
.SYNOPSIS
Print a random quotation
.DESCRIPTION
Uses glow for markdown rendering

Considering switching to another tool to render markdown links into iTerm2-clickable output (glow still lacks OSC8)
But! Don’t switch from glow → mdcat just for OSC8 links: mdcat is archived (2025-01-10)
MAYBE script to convert links to OSC8 for clean iTerm2-clickable output.
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$all = sls '~' ~/notes/MyNotes/Quotations.md
$all += sls '~' (Join-Path (Get-Bin) "apps/stoicism.md")

$random = $all | Get-Random
if (Get-Command glow -ErrorAction SilentlyContinue) {
  $random.Line | glow --width 0
} else {
  $random.Line
  Write-Warning "glow not found, falling back to cat"
}
