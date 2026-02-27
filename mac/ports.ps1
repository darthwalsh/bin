<#
.SYNOPSIS
Finds listening ports
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

write-Warning "MAYBE Try pkgx witr --port `$PORT --short"
sudo lsof -iTCP -sTCP:LISTEN -n -P
