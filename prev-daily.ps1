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

[CmdletBinding(SupportsShouldProcess)]
param(
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$notes = Get-ChildItem ~/notes/MyNotes/inbox -Filter "*.md"

$dateNotes = $notes | Where-Object {
  if ($_.Name -match '^(\d{4}-\d{2}-\d{2})\.md$') {
    $noteDate = $matches[1]
    $noteDate -notin (ymd), (ymd -Days +1)
  }
} | Sort-Object -Descending

if (@($dateNotes).Count -ne 0) {
  foreach ($note in $dateNotes) {
    Start-Process "obsidian://open?paneType=tab&path=$([uri]::EscapeDataString($note.FullName))"
  }
  return
}

"No daily notes!"
# TODO should query this dynamically: https://chatgpt.com/share/68eeb509-684c-8011-98ff-c5a6f72d1dc2
if ($PSCmdlet.ShouldProcess('Gmail inbox', "Open in browser")) {
  Start-Process 'https://mail.google.com/mail/u/0/#search/in%3Ainbox+is%3Aimportant+is%3Aread'
}

<#
Also: first query for how many lit-read tags left, and if it's less than 5 open a tab to add more

Future in=baskets to rotate through:
- anything in Tasks.md
Get the pinned obsidian tabs, and find anything from the past?
#>

