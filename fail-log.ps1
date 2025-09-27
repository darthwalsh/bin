<#
.SYNOPSIS
Log failure to inbox
.PARAMETER Kind
Error category code
.PARAMETER File
The file that caused the error, or the log file
#>

param(
  [Parameter(Mandatory=$true)] [string] $Kind,
  [Parameter(Mandatory=$true)] [string] $File
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function uri($p) {
  $abs = Resolve-Path $p
  $uri = [System.Uri]::new($abs)
  $uri.AbsoluteUri
}

$Logfile = $File + ".log"
$extra = if (Test-Path $Logfile) {
  "`n>and [.log]($(uri $Logfile))"
}
"> [!ERROR] ``$Kind`` see [$(Split-Path -Leaf $File)]($(uri $File))$extra" | in
