. (Join-Path $PSScriptRoot ".." "Microsoft.PowerShell_profile.ps1")

PrependPATH $PSScriptRoot
if (Test-Path ~/.pyenv) { Write-Warning "switch to uv!" }
