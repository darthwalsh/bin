<#
.SYNOPSIS
create TMP Venv and Activate
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$tmp = Join-Path "Temp:" "DEL-$(Get-Date -Format "yyyyMMdd-HH-mm-ss.ff")"

# HACK to get a real filesystem path that doesn't exist
New-Item -ItemType Directory -Path $tmp | Out-Null
$path = (Convert-Path $tmp)
Remove-Item $path -Recurse | Out-Null

va $path -NoInstall
