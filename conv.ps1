<#
.SYNOPSIS
ConvertFrom JSON, YAML, CSV, or TOML
.DESCRIPTION
If given a path-like object, will read the file using the file extension.
Otherwise, will attempt to parse as YAML
#>

param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
    [string] $Content
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

if (Test-Path -LiteralPath $Content) {
    $ext = [System.IO.Path]::GetExtension($Content)
    $bytes = Get-Content -LiteralPath $Content -Raw 
    switch ($ext) {
        ".csv" { $bytes | ConvertFrom-Csv }
        ".json" { $bytes | ConvertFrom-Json }
        ".yaml" { $bytes | ConvertFrom-Yaml }
        ".yml" { $bytes | ConvertFrom-Yaml }

        # Little messy
        ".toml" { $bytes | python -c "import tomllib, sys, json; o = tomllib.load(sys.stdin.buffer); print(json.dumps(o))" | ConvertFrom-Json }
    }
    return
}

$Content | ConvertFrom-Yaml
