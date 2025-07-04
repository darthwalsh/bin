<#
.SYNOPSIS
ConvertFrom JSON, YAML, CSV, or TOML
.DESCRIPTION
If given a valid path, will parse the file using the file extension.
Otherwise, will attempt to parse as YAML.
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
  [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
  [string] $Content
)

begin {
  $script:ErrorActionPreference = "Stop"
  Set-StrictMode -Version Latest
  $allLines = @()
}

process {
  $allLines += $Content
}

end {
  $joined = $allLines -join "`n"

  if (Test-Path -LiteralPath $joined) {
    $ext = [System.IO.Path]::GetExtension($joined)
    $bytes = Get-Content -LiteralPath $joined -Raw 
    switch ($ext) {
      ".csv" { $bytes | ConvertFrom-Csv }
      ".json" { $bytes | ConvertFrom-Json }
      ".json5" { $bytes | ConvertFrom-Json }
      ".yaml" { $bytes | ConvertFrom-Yaml }
      ".yml" { $bytes | ConvertFrom-Yaml }

      # MAYBE Little messy
      ".toml" { $bytes | python -c "import tomllib, sys, json; o = tomllib.load(sys.stdin.buffer); print(json.dumps(o))" | ConvertFrom-Json }

      default {
        throw "Unsupported file type: $ext"
      }
    }
    return
  }

  $joined | ConvertFrom-Yaml
}
