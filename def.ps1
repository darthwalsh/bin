<#
.SYNOPSIS
Prints the definition of a file or function
.PARAMETER File
Command to create or edit. Can create parent directories
#>

param(
  [Parameter(Mandatory = $true)]
  [string] $File
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function noHome($p) {
  $homeRegex = "^" + [regex]::escape($Home)
  $p -replace $homeRegex, '~'
}

function printPythonFiles($content) {
  # This is a bit hacky; but better than trying to eval `(Join-Path $PSScriptRoot strava_cook.py)`
  foreach ($match in $content | Select-String '\w+\.py' ) {
    $pyFile = $match.Matches.Value
    foreach ($found in Get-ChildItem -Recurse $PSScriptRoot $pyFile) {
      " "
      Write-Host $found.FullName -ForegroundColor Blue
      Get-Content $found
    }
  }
}

Get-Command $File -All -ErrorAction SilentlyContinue | ForEach-Object { 
  $cmd = $_

  switch ($cmd.CommandType) {
    Alias {
      $cmd.DisplayName
    }
    Application {
      noHome $cmd.Source

      $extension = [System.IO.Path]::GetExtension($cmd.Source)

      if (Test-Shebang $cmd.Source) {
        Get-Content $cmd.Source
      }
      elseif ($extension -and $extension -ne ".exe") {
        Get-Content $cmd.Source
      }
      else {
        "[binary]"
      }
    }
    Function {
      noHome $cmd.ScriptBlock.File
      $cmd.Definition
    }
    ExternalScript {
      noHome $cmd.Source
      
      $content = Get-Content $cmd.Source
      
      $i = $content.IndexOf("Set-StrictMode -Version Latest")
      if ($i -ge 0) {
        $pStart = $content.IndexOf('param(')
        $pEnd = $content.IndexOf(')')
        if ($pStart -ge 0 -and $pEnd -gt $pStart -and $pEnd -lt $i) {
          $content | Select-Object -Skip $pStart -First ($pEnd - $pStart + 1)
        }

        $content | Select-Object -skip ($i + 2)

        printPythonFiles $content
      } else {
        $content
      }
    }
    default {
      $cmd.Name
      $cmd.Definition
    }
  }
  " "
}
