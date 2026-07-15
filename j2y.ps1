<#
.SYNOPSIS
Converts JSON from stdin and writes YAML to stdout
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$Input | uv run (Join-Path $PSScriptRoot j2y.py)
