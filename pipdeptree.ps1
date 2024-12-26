<#
.SYNOPSIS
Runs pipdeptree against the current venv python
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# On windows this script prints "⚠️  pipdeptree is already on your PATH and installed at C:\code\bin\pipdeptree.PS1. Downloading and running anyway."
# MAYBE squash this or rename the PS1 or contribute upstream
pipx run pipdeptree --python auto @args
