<#
.SYNOPSIS
Sets up .cursor commands in all repos
.DESCRIPTION
Add files to $cursorFiles as needed.

RULES currently need to be symlinked, but they might implement later! https://forum.cursor.com/t/user-rules-are-not-recognized-from-folder-cursor-rules/144739/7
Outdated for COMMANDS: https://cursor.com/docs/agent/chat/commands Could migrate to ~/.cursor/commands/pr.md
.PARAMETER Remove
Remove any added symlinks. (Call before migrating to new rule schema.)
#>

[CmdletBinding(SupportsShouldProcess)]
param(
  [switch] $Remove
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

throw "TODO need to ensure that all-git-dirs files don't have work vs personal overwrites"

# Source-of-truth: any full paths listed in dotfiles/README.md that contain ".cursor/".
$dotfilesDir = Join-Path (Get-Bin) "dotfiles"
$dotfilesReadme = Join-Path $dotfilesDir "README.md"
$cursorFiles = @(Select-String '\.cursor/(\S+)$' $dotfilesReadme | % { $_.Matches.Groups[1].Value })

Write-Verbose "cursorFiles: $cursorFiles"

if ($cursorFiles.Count -eq 0) {
  throw "No .cursor/ entries found in $dotfilesReadme"
}

function Use-Location($Path, $Body) {
  Push-Location -LiteralPath $Path
  try { & $Body }
  finally { Pop-Location }
}

foreach ($proj in all-git-dirs) {
  Use-Location $proj {
    if ($Remove) {
      if (!(Test-Path ".cursor")) { return } # Get-ChildItem on a dir that doesn't exist will recurse the whole tree??
      foreach ($file in Get-ChildItem -Path ".cursor" -File -Recurse) {
        if ($file.LinkType -eq 'SymbolicLink') {
          "rm $file -> $($file.Target)"
          Remove-Item $file
        } else {
          "skipping $file"
        }
      }
      continue
    }

    foreach ($cursorFile in $cursorFiles) {
      $dotfileName = Split-Path -Leaf $cursorFile
      $linkPath = ".cursor/$cursorFile"
    
      $linkDir = Split-Path -Parent $linkPath
      New-Item -ItemType Directory -Path $linkDir -Force | Out-Null
    
      $targetPath = Resolve-Path (Join-Path $dotfilesDir $dotfileName)
      New-Item -ItemType SymbolicLink -Target $targetPath -Path $linkPath -Force | Out-Null
    }

    "Added .cursor/ links to $($proj.Name)"
  }
}
