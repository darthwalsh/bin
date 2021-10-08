<#
.SYNOPSIS
Activate venv
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

try {
  deactivate
}
catch {
}


for ($dir = gi (Get-Location); ; $dir = $dir.Parent) {
  if (!$dir) {
    $newEnvParent = Get-Location
    try {
      $gitRoot = git rev-parse --show-toplevel
      if ($gitRoot) { $newEnvParent = $gitRoot }
    } catch { }
    $envDir = Join-Path $newEnvParent "env"
    $userChoice = (Read-Host "Create venv directory [$envDir]")
    $envDir = $userChoice ? $userChoice : $envDir
    
    py -m venv $envDir
    Write-Host "Created venv directory $envDir" -ForegroundColor Green
    break
  }
  # walk up the path until we find a directory that contains an env directory

  $envDir = gci $dir -Directory *env*
  if (@($envDir).Count -gt 1) { throw "Found multiple env: $($envDir.Name)" }
  if (@($envDir).Count -eq 1) { break }
}

$activate = @(
  (Join-Path $envDir Scripts Activate.ps1),
  (Join-Path $envDir bin Activate.ps1)
) | ? { Test-Path $_ }

if (@($activate).Length -ne 1) { throw $activate.Name }

. $activate -prompt 'v'

$requirementsTXT = Join-Path $envDir .. "requirements.txt"
if (Test-Path $requirementsTXT) {
  py -m pip install -q -r $requirementsTXT
}

if (Test-Path .env) {
  Source-Anything .env
}
