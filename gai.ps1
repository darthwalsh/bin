<#
.SYNOPSIS
git commit the staged files, marking author as AI. Then opens in obsidian
#>

param(
  [string] $Message = "AI generated"
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

Write-Warning "MAYBE not sure about this. Maybe, look back at old commit instead, write commit hashes to gai.txt?, then filter from history in deslop?"
# $stagedFiles = git diff --cached --name-only
$Message | git commit --author="AI <ai@local>" --file=-

# foreach ($file in $stagedFiles) {
#   obsidian open vault=notes "path=bin/$file" newtab
# }
