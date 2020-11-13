<#
.SYNOPSIS
Prints the definition of a file or function
.PARAMETER File
Command to run
#>

param(
  [Parameter(Mandatory = $true)]
  [string] $File
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

Get-Command $File -All -ErrorAction SilentlyContinue | % { 
  $cmd = $_

  switch ($cmd.CommandType) {
    Alias {
      $cmd.DisplayName
    }
    Application {
      $cmd.Source -replace "^$Home", '~'

      $bytes = Get-Content $cmd.Source -AsByteStream -TotalCount 2
      $isShebang = '#!' -eq -join [char[]]$bytes

      # TODO .bat?
      if ($isShebang) {
        Get-Content $cmd.Source
      }
      else {
        "[binary]"
      }
    }
    ExternalScript {
      $cmd.Source -replace "^$Home", '~'
      Get-Content $cmd.Source
    }
    default {
      $cmd.Name
      $cmd.Definition
    }
  }
  " "
}
