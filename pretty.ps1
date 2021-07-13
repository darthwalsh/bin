<#
.SYNOPSIS
Runs prettier
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$config = Join-Path $PSScriptRoot prettierrc.yaml
$gitignore = Join-Path (git rev-parse --show-toplevel) .gitignore
prettier --config $config --ignore-path $gitignore --write .
