<#
.SYNOPSIS
Runs pipdeptree against the current venv python
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# MAYBE could use `uv tree` optionally with --script for PEP 723 style imports.
pipx run pipdeptree --python auto @args
