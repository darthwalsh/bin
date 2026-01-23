#!/usr/bin/env pwsh
# Install global dependencies required for tests

$script:ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $true
Set-StrictMode -Version Latest

Write-Host "Installing jsonc-cli required for jsonc, called in python testing..."
npm install --global jsonc-cli
