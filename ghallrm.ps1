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
    $current = Get-GitBranch 2> $null
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


# TODO allgit, then maybe Test-GitWorktree should throw on not-in-git
foreach ($dir in Get-ChildItem $Repos -Directory) {
  if (-not (Test-Path $dir)) {
    Write-Verbose "$dir was deleted while we were running?"
    continue
  }

  Push-Location $dir

  # Skip linked worktrees - ghrm on the main repo handles them
  if (Test-GitWorktree) {
    Write-Verbose "Skipping $dir, it's a linked worktree"
    Pop-Location
    continue
  }

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
