<#
.SYNOPSIS
Cursor CLI headless answer question
.DESCRIPTION
Goal: Sub-1-second latency. Not achievable with CLI tools due to some startup overhead?

Originally used gh COPilot but that was deprecated: https://github.blog/changelog/2025-09-25-upcoming-deprecation-of-gh-copilot-cli-extension/
Tried GitHub Copilot CLI https://github.com/github/copilot-cli but that took 9 seconds.
Tried `agent` https://cursor.com/docs/cli but that took 7 seconds.
Now using claude: https://code.claude.com/docs because faster with cheapest model


MAYBE: Direct API call would be faster (~200-500ms for Haiku) but:
- With separate ANTHROPIC_API_KEY subscription then could use api.anthropic.com/v1/messages
    - Try https://github.com/antonmedv/howto for perf and keybinding
- Cursor Enterprise doesn't expose API access for direct calls
.EXAMPLE
PS> cop 'give me curl command that answers: what http status response does carlwa.com give'
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

claude --model haiku --print @args
