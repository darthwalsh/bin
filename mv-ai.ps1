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
  
  rename-space $file
}

Get-ChildItem ~/Downloads/*.md | Move-Item -Destination ~/notes/MyNotes/inbox/ai -PassThru

$recents = Get-ChildItem ~/notes/MyNotes/inbox/ai/*.md | Sort-Object CreationTime | Select-Object -First 6
foreach ($recent in $recents) {
  echo "trash $($recent.FullName)"
}
if ($PSCmdlet.ShouldProcess($recents[0].Name, "Open in Obsidian")) {
  obsidian open vault=notes "path=MyNotes/inbox/ai/$($recents[0].Name)" newtab
}
