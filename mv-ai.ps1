<#
.SYNOPSIS
MoVe exports of AI chat to obsidian inbox
#>

[CmdletBinding(SupportsShouldProcess)]
param()

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

foreach ($file in Get-ChildItem ~/Downloads/*.md) {
  (Get-Content $file.FullName) -replace "## 👤 You", "# 👤 You" | Set-Content $file.FullName
  # Would be nice to add a short summary of my chat in the header, but not sure if better to use LLM or script it?
}

Get-ChildItem ~/Downloads/*.md | Move-Item -Destination ~/notes/MyNotes/inbox/ai -PassThru

$recents = Get-ChildItem ~/notes/MyNotes/inbox/ai/*.md | Sort-Object LastWriteTime -Descending | Select-Object -First 3
foreach ($recent in $recents) {
  echo "trash $($recent.FullName)"
}
Start-Process "obsidian://open?paneType=tab&path=$([uri]::EscapeDataString($recents[0].FullName))"
