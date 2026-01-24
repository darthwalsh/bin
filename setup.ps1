#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Setup script for bin repository dependencies

.DESCRIPTION
    Installs required dependencies (uv, oh-my-posh) using available package managers.
    Tries package managers in order: pkgm -> brew -> scoop

.EXAMPLE
    ./setup.ps1
#>

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

function Test-CommandExists {
    param([string]$Command)
    $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

function Install-WithPkgm {
    param([string]$Package)
    Write-Host "Installing $Package with pkgm..." -ForegroundColor Cyan
    pkgm i $Package
}

function Install-WithBrew {
    param([string]$Package)
    Write-Host "Installing $Package with brew..." -ForegroundColor Cyan
    brew install $Package
}

function Install-WithScoop {
    param([string]$Package, [string]$Bucket = $null)
    Write-Host "Installing $Package with scoop..." -ForegroundColor Cyan
    if ($Bucket) {
        scoop bucket add $Bucket -ErrorAction SilentlyContinue
    }
    scoop install $Package
}

function Install-Dependency {
    param(
        [string]$Name,
        [string]$PkgmName = $Name,
        [string]$BrewName = $Name,
        [string]$ScoopName = $Name,
        [string]$ScoopBucket = $null
    )

    if (Test-CommandExists $Name) {
        Write-Host "✓ $Name is already installed" -ForegroundColor Green
        return $true
    }

    Write-Host "Installing $Name..." -ForegroundColor Yellow

    if (Test-CommandExists 'pkgm') {
        try {
            Install-WithPkgm $PkgmName
            return $true
        }
        catch {
            Write-Warning "Failed to install $Name with pkgm: $_"
        }
    }

    if (Test-CommandExists 'brew') {
        try {
            Install-WithBrew $BrewName
            return $true
        }
        catch {
            Write-Warning "Failed to install $Name with brew: $_"
        }
    }

    if (Test-CommandExists 'scoop') {
        try {
            Install-WithScoop $ScoopName -Bucket $ScoopBucket
            return $true
        }
        catch {
            Write-Warning "Failed to install $Name with scoop: $_"
        }
    }

    Write-Error "Could not install ${Name}: No package manager available (tried: pkgm, brew, scoop)"
    return $false
}

Write-Host "=== bin repository setup ===" -ForegroundColor Magenta
Write-Host ""

# Install uv
Install-Dependency -Name 'uv' -PkgmName 'uv' -BrewName 'uv' -ScoopName 'uv'

# Install oh-my-posh
Install-Dependency -Name 'oh-my-posh' -PkgmName 'oh-my-posh' -BrewName 'oh-my-posh' -ScoopName 'oh-my-posh'

Write-Host ""
Write-Host "=== Setup complete! ===" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Add this to your PowerShell profile ($PROFILE):"
Write-Host "   . ~/bin/lnx/Microsoft.PowerShell_profile.ps1" -ForegroundColor Yellow
Write-Host ""
Write-Host "2. For bash/zsh, add to ~/.bashrc or ~/.zshrc:"
Write-Host "   source ~/bin/bash_aliases" -ForegroundColor Yellow
Write-Host "   PATH=~/bin:~/bin/lnx:\$PATH" -ForegroundColor Yellow
