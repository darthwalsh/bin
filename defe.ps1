<#
.SYNOPSIS
Edit a command definition
.PARAMETER File
Command to edit
.PARAMETER Current
Open in the current editor window instead of the bin/ repo window
#>

param(
    [Parameter(Mandatory=$true)]
    [string] $File,
    [switch] $Current
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# The "current window" uses env var manually set in the each .code-workspace file 
$editorArgs = @(if ($Current) {
  $ENV:WORKSPACE_FILE ?? '.'
})

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
      code @editorArgs $cmd.Source
    }
    elseif ($extension -and $extension -ne ".exe") {
      code @editorArgs $cmd.Source
    }
    else {
      "[binary]"
    }
  }
  Function {
    if ($cmd.ScriptBlock.File) {
      
      $defLine = @(Select-String "^function $($cmd.Name)" $cmd.ScriptBlock.File)
      if ($defLine.Length -eq 1) {
        code @editorArgs --goto "$($cmd.ScriptBlock.File):$($defLine[0].LineNumber)"
      } else {
        code @editorArgs "$($cmd.ScriptBlock.File)"
      }

    }
    else {
      "[interactive function]"
    }
  }
  ExternalScript {
    code @editorArgs $cmd.Source
  }
  default {
    $cmd
  }
}

