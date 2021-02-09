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

Get-Command $File -All -ErrorAction SilentlyContinue | % { 
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
        $content | Select-Object -skip ($i + 2)
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
