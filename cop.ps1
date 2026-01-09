<#
.SYNOPSIS
Cursor CLI headless answer question
.DESCRIPTION
See https://cursor.com/docs/cli/overview
Used to use gh copilot but that was deprecated: https://github.blog/changelog/2025-09-25-upcoming-deprecation-of-gh-copilot-cli-extension/
.EXAMPLE
PS> cop 'how '
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

cursor-agent --print @args

