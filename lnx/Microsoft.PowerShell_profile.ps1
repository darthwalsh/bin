. (Join-Path $PSScriptRoot ".." "Microsoft.PowerShell_profile.ps1")

PrependPATH $PSScriptRoot
if (Test-Path ~/.pyenv) { prependPATH ~/.pyenv/shims }
