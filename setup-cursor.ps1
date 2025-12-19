<#
.SYNOPSIS
Sets up .cursor commands
.DESCRIPTION
Right now just links /pr but can set up more later
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

Write-Warning "TODO: This is outdated for COMMANDS: https://cursor.com/docs/agent/chat/commands Migrate to ~/.cursor/commands/pr.md -- but RULES still need to be symlinked, but they might implement later! https://forum.cursor.com/t/user-rules-are-not-recognized-from-folder-cursor-rules/144739/7"

New-Item -ItemType Directory -Path .cursor/commands -Force | Out-Null

$targetPath = Resolve-Path ~/code/bin/dotfiles/pr.md
New-Item -ItemType SymbolicLink -Target $targetPath -Path ".cursor/commands/pr.md"
