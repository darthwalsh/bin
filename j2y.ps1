<#
.SYNOPSIS
Converts JSON from stdin and writes YAML to stdout
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$Input | pipx run (Join-Path $PSScriptRoot j2y.py)
