<#
.SYNOPSIS
Sets up .cursor commands
.DESCRIPTION
Right now just links /pr but can set up more later
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

New-Item -ItemType Directory -Path .cursor/commands -Force | Out-Null

$targetPath = Resolve-Path ~/code/bin/dotfiles/pr.md
New-Item -ItemType SymbolicLink -Target $targetPath -Path ".cursor/commands/pr.md"
