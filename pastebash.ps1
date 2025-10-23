<#
.SYNOPSIS
WIP Run a bash script on your clipboard
.DESCRIPTION
Started with idea to re-write env var from $VAR to $env:VAR (but my `export` also sets $global)
Probably NOT worth it; theres's dozens of syntax differences: https://chatgpt.com/share/68f52afd-0a94-8011-b7e8-b1d192da5167
ALSO what about binary data being piped?
ALSO handle input redirecting: <file cat would become gc cat -raw

A full solution would be a syntax tree rewrite -- not worth it!
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

raise "WIP this needs to be rewritten to use a LLM to transpile bash to powershell"

$clip = Get-Clipboard
# Fixes backslash line continuation issues
$clip = $clip -replace '\\\r?\n', ' '
$clip
