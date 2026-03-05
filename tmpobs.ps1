<#
.SYNOPSIS
Create a new temporary obsidian file in inbox/
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$file = (ymd -time) + ".md"
$path = Join-Path ~/notes/MyNotes/inbox $file
New-Item $path -ItemType File | fn

obsidian open vault=notes "path=MyNotes/inbox/$file" newtab
