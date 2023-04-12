<#
.SYNOPSIS
Activate venv
#>

param (
  [string] $Name,
  [switch] $NoInstall
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

try {
  deactivate
}
catch {
}

if ($Name) {
  $envDir = $Name
} else {
  for ($dir = gi (Get-Location); ; $dir = $dir.Parent) {
    if (!$dir) {
      $newEnvParent = Get-Location
      try {
        $gitRoot = git rev-parse --show-toplevel
        if ($gitRoot) { $newEnvParent = $gitRoot }
      } catch { }
      $newEnvParent = Convert-Path $newEnvParent # Convert i.e. Temp:/ path to a real filesystem path
      $envDir = Join-Path $newEnvParent "env"
      $userChoice = (Read-Host "Create venv directory [$envDir]")
      $envDir = $userChoice ? $userChoice : $envDir
      break
    }
    # walk up the path until we find a directory that contains an env directory

    $envDir = gci $dir -Directory *env*
    if (@($envDir).Count -gt 1) { throw "Found multiple env: $($envDir.Name)" }
    if (@($envDir).Count -eq 1) { break }
  }
}

if (-not (Test-Path $envDir)) {
  py -m venv $envDir
  Write-Host "Created venv directory $envDir" -ForegroundColor Green
}

$activate = @(
  (Join-Path $envDir Scripts Activate.ps1),
  (Join-Path $envDir bin Activate.ps1)
) | ? { Test-Path $_ }

if (@($activate).Length -ne 1) { throw $activate.Name }

. $activate -prompt 'v'

if (-not $NoInstall) {
  py -m pip install -q --upgrade pip

  $requirementsTXT = Join-Path $envDir .. "requirements.txt"
  if (Test-Path $requirementsTXT) {
    py -m pip install -q -r $requirementsTXT
  }
}

if (Test-Path .env) {
  Source-Anything .env
}
