<#
.SYNOPSIS
Converts JSON from stdin and writes YAML to stdout
.NOTES
Might need to run `python -m pip install pyyaml`
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$Input | python (Join-Path $PSScriptRoot j2y.py)
