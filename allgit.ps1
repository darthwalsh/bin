<#
.SYNOPSIS
Runs for each git repo subfolder
.DESCRIPTION
Pass a command and args, or a script block.
.PARAMETER CommandArgs
A command with its arguments/switches, or a single script block.
.EXAMPLE
PS> allgit git diff --exit-code
.EXAMPLE
PS> allgit { if (git status -s) { git status } }
.EXAMPLE
PS> allgit gitpr -create
.EXAMPLE
PS> allgit Get-GitDefaultBranch -Refresh
#>

param(
  [Parameter(ValueFromRemainingArguments = $true)]
  [object[]] $CommandArgs
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function ForEachGit ($sb) {
  Push-Location
  try {
    Get-ChildItem -Directory | ForEach-Object {
      Push-Location $_.FullName
      Write-Host "cd $(Get-Item . | ForEach-Object Name)" -ForegroundColor Magenta
      if (-not (Test-Path .git)) {
        return
      }

      & $sb
    }
  }
  finally {
    Pop-Location
  }
}

ForEachGit {
  if ($CommandArgs[0] -is [scriptblock]) {
    . $CommandArgs[0]
  } else {
    # Reconstruct the command line so PowerShell re-parses switches (e.g. -Refresh).
    # Array splatting only passes positional args, dropping named switches (the reason agit needed -Expr).
    # Input is the user's own interactive command, not untrusted data.
    $parts = $CommandArgs | ForEach-Object {
      $s = [string]$_
      if ($s -match '\s' -or $s -eq '') { '"' + ($s -replace '"', '`"') + '"' } else { $s }
    }
    Invoke-Expression ($parts -join ' ')
  }
}
