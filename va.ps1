<#
.SYNOPSIS
Activate venv
#>

[CmdletBinding(SupportsShouldProcess = $true)]
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
      
      $gitIgnore = Join-Path $newEnvParent ".gitignore"
      if (Test-Path $gitIgnore) {
        Write-Host "Searched /env/ in $gitIgnore" -ForegroundColor Blue
        rg -v '^#' $gitIgnore | rg env
      }

      $envDir = Join-Path $newEnvParent ".venv" # Default to hidden folder
      $userChoice = (Read-Host "Create venv directory [default: $envDir]")
      $envDir = $userChoice ? $userChoice : $envDir
      break
    }
    # walk up the path until we find a directory that contains an env directory

    $envDir = gci $dir -Directory *env* -Force
    $envDir = $envDir | ? Name -notin @('ansible-env', '.pyenv', '.venvs') # HACK to exclude these directories
    if (@($envDir).Count -gt 1) {
      foreach ($env in $envDir) {
        $py = Join-Path $env.FullName bin python
        $pyVer = if (Test-Path $py) {
          & $py -V
        } else {
          "FILE_NOT_FOUND"
        }
        # MAYBE somehow diff the `pip freeze`
        Write-Host "Found env: $py --version $pyVer" -ForegroundColor Yellow
      }
      throw "Found multiple env: $($envDir.Name)"
    }
    if (@($envDir).Count -eq 1) { break }
  }
}

if (-not (Test-Path $envDir)) {
  if ($PSCmdlet.ShouldProcess($envDir, "Create venv directory")) {
    py -m venv $envDir
  }
  Write-Host "Created venv directory $envDir" -ForegroundColor Green
}

$activate = @(
  (Join-Path $envDir Scripts Activate.ps1),
  (Join-Path $envDir bin Activate.ps1)
) | ? { Test-Path $_ }

if (@($activate).Length -ne 1) { throw $activate.Name }

if ($PSCmdlet.ShouldProcess($activate, "Activate venv directory")) {
  . $activate -prompt 'v'
}

if (-not $NoInstall) {
  if ($PSCmdlet.ShouldProcess($envDir, "Upgrade pip")) {
    py -m pip install -q --upgrade pip
  }
  if ($Name) {
    Write-Warning "Should disable looking for requirements.txt relative to $Name"
  }

  $requirementsTXT = Join-Path $envDir .. "requirements.txt"
  if (Test-Path $requirementsTXT) {
    if ($PSCmdlet.ShouldProcess($envDir, "Install $requirementsTXT")) {
      py -m pip install -q -r $requirementsTXT
    }
  } else {
    Write-Host "No found: $requirementsTXT" -ForegroundColor Gray
  }
}

if (Test-Path .env) {
  if ($PSCmdlet.ShouldProcess('.env', "Source .env")) {
    $isScript = [bool](Select-String '^export ' .env)
    if ($isScript) {
      try {
        Source-Anything .env
      }
      catch {
        Write-Error "Failed to source .env: $_"
      }
    } else {
      foreach ($line in Get-Content .env) {
        export $line
      }
    }
  }
}
