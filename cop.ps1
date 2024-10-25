<#
.SYNOPSIS
gh COPilot suggest $args
.OUTPUTS
Renders explanation of the command.
.EXAMPLE
PS> cop 'how '
#>

param(
    [Parameter(Mandatory=$true)]
    [string] $Command
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# Even if GH_HOST is set to GHE, use the normal GitHub server
gh copilot --hostname 'github.com' suggest -t shell $Command


# MAYBE Consider using --shell-out to allow Execute option to execute instead of copy-paste
# MAYBE Automate using screen? https://gist.github.com/Pl8tinium/3702c356a83b7363f3ab769d6ec47e2a because https://github.com/github/gh-copilot/issues/37
