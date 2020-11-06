<#
.SYNOPSIS
Converts JSON from stdin and writes YAML to stdout
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$Input | python -c 'import sys, yaml, json; print(yaml.dump(json.loads(sys.stdin.read())))'
