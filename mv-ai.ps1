<#
.SYNOPSIS
MoVe exports of AI chat to obsidian inbox
#>

[CmdletBinding(SupportsShouldProcess)]
param()

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

Get-ChildItem ~/Downloads/*.md | Move-Item -Destination ~/notes/MyNotes/inbox/ai -PassThru

foreach ($file in Get-ChildItem ~/notes/MyNotes/inbox/ai/*.md) {
  (Get-Content $file.FullName) -replace "## 👤 You", "# 👤 You" | Set-Content $file.FullName
  # Would be nice to add a short summary of my chat in the header, but not sure if better to use LLM or script it?
}

$mostRecentNote = Get-ChildItem ~/notes/MyNotes/inbox/ai/*.md | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if ($mostRecentNote) {
  Start-Process "obsidian://open?path=$([uri]::EscapeDataString($mostRecentNote.FullName))"
}
