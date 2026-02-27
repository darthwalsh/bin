<#
.SYNOPSIS
Use GHRM in ALL repos 
.PARAMETER Repos
Directory that has subfolders with repos
.EXAMPLE
PS> ghallrm ~/code
#>

[CmdletBinding(SupportsShouldProcess=$true)]
param(
  [Parameter(Mandatory=$true)]
  [string] $Repos
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest


function GitBranchOffDefault {
  try {
    $current = Get-GitBranch.ps1 2> $null
  } catch { 
    Write-Verbose "Skipping $dir, not a git repo"
    return ""
  }

  $default = Get-GitDefaultBranch
  if ($current -ne $default) {
    return $current
  }
  # MAYBE also run git status -s to see if there are any changes
}


foreach ($dir in Get-ChildItem $Repos -Directory) {
  Push-Location $dir

  # Skip linked worktrees - ghrm on the main repo handles them
  try {
    $gitDir    = git rev-parse --git-dir 2>$null
    $commonDir = git rev-parse --git-common-dir 2>$null
    if ($gitDir -and $gitDir -ne $commonDir) {
      Write-Verbose "Skipping $dir, it's a linked worktree"
      Pop-Location
      continue
    }
  } catch {}

  $offDefault = GitBranchOffDefault

  if (!$offDefault) {
    Pop-Location
    continue
  }
  Write-Verbose "Process $dir"

  ""
  "$($dir.Name): on branch $offDefault"
  
  try {
    git status -s
    ghrm
  } catch {
    Write-Warning "Not quitting on error $_"
  }

  Pop-Location
}
