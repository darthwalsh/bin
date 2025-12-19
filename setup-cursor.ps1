<#
.SYNOPSIS
Sets up .cursor commands
.DESCRIPTION
Add files to $cursorFiles as needed.
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

Write-Warning "TODO: This is outdated for COMMANDS: https://cursor.com/docs/agent/chat/commands Migrate to ~/.cursor/commands/pr.md -- but RULES still need to be symlinked, but they might implement later! https://forum.cursor.com/t/user-rules-are-not-recognized-from-folder-cursor-rules/144739/7"

$cursorFiles = @(
    "commands/pr.md",
    "rules/markdown.md",
    "rules/pwsh.md"
)

foreach ($cursorFile in $cursorFiles) {
    $dotfileName = Split-Path -Leaf $cursorFile
    $linkPath = ".cursor/$cursorFile"
    
    $linkDir = Split-Path -Parent $linkPath
    New-Item -ItemType Directory -Path $linkDir -Force | Out-Null
    
    $targetPath = Resolve-Path ~/code/bin/dotfiles/$dotfileName
    New-Item -ItemType SymbolicLink -Target $targetPath -Path $linkPath -Force | Out-Null
}
