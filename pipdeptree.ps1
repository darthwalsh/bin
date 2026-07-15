<#
.SYNOPSIS
Runs pipdeptree against the current venv python
.DESCRIPTION
Like uv tree but works on any venv
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# MAYBE could use `uv tree` optionally with --script for PEP 723 style imports.
uvx pipdeptree --python auto @args
