<#
.SYNOPSIS
MoVe exports of AI chat to obsidian inbox
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

gci ~/Downloads/*.md | Move-Item -Destination ~/notes/MyNotes/inbox/ai

foreach ($file in gci ~/notes/MyNotes/inbox/ai/*.md) {
  (Get-Content $file.FullName) -replace "## 👤 You", "# 👤 You" | Set-Content $file.FullName
}

$mostRecentNote = gci ~/notes/MyNotes/inbox/ai/*.md | Sort-Object LastWriteTime -Descending | Select-Object -First 1
Start-Process "obsidian://open?path=$([uri]::EscapeDataString($mostRecentNote.FullName))"
