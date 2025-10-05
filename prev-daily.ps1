<#
.SYNOPSIS
Open a past daily note in Obsidian
.DESCRIPTION
Obsidian Learning Part I: Capture - YouTube: https://www.youtube.com/watch?v=i8h4eTcxF9E
Introduces temporal contract:
> 1. You must store all fleeting notes safely in a single trusted system.
> 2. Every day you must read yesterday's fleeting notes.
-- this opens the most recent daily note (excluding today)
.EXAMPLE
PS> .\Script.ps1 foobar
#>

param(
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$notes = Get-ChildItem ~/notes/MyNotes/inbox -Filter "*.md"
$today = (Get-Date).Date

$dateNotes = $notes | Where-Object {
  $ymd = $_.Name -match '^\d{4}-\d{2}-\d{2}\.md$'
  $today = $_.Name -eq "$(ymd).md"
  $ymd -and !$today
} | Sort-Object -Descending

if (@($dateNotes).Count -eq 0) {
  return "No daily notes!"
}

$mostRecentNote = $dateNotes[0]
$mostRecentNote.FullName

Start-Process "obsidian://open?path=$([uri]::EscapeDataString($mostRecentNote.FullName))"

