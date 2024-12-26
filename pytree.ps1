<#
.SYNOPSIS
Runs pipdeptree against the current venv python
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

pipx run pipdeptree --python auto @args
