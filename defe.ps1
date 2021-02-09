<#
.SYNOPSIS
Edit a command definition
.PARAMETER File
Command to edit
#>

param(
    [Parameter(Mandatory=$true)]
    [string] $File
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$cmds = @(Get-Command $File -All)

if ($cmds.Length -ne 1) {
  $cmds
  Write-Warning "$File not a unique command"
}

$cmd = $cmds[0]

switch ($cmd.CommandType) {
  Application {
    $extension = [System.IO.Path]::GetExtension($cmd.Source)

    if (Test-Shebang $cmd.Source) {
      code $cmd.Source
    }
    elseif ($extension -and $extension -ne ".exe") {
      code $cmd.Source
    }
    else {
      "[binary]"
    }
  }
  Function {
    if ($cmd.ScriptBlock.File) {
      
      $defLine = @(Select-String "^function $($cmd.Name)" $cmd.ScriptBlock.File)
      if ($defLine.Length -eq 1) {
        code --goto "$($cmd.ScriptBlock.File):$($defLine[0].LineNumber)"
      } else {
        code "$($cmd.ScriptBlock.File)"
      }

    }
    else {
      "[interactive function]"
    }
  }
  ExternalScript {
    code $cmd.Source
  }
  default {
    $cmd
  }
}

