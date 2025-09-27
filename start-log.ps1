<#
.SYNOPSIS
Start transcript for logging
.PARAMETER Folder
Folder in home directory
.OUTPUTS
Log path
.EXAMPLE
PS> .\Script.ps1 foobar
#>

param(
    [Parameter(Mandatory=$true)]
    [string] $Folder
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$logDir = Join-Path $HOME $Folder
New-Item -ItemType Directory -Force -Path $logDir | Out-Null
$log = join-path $logDir "$(ymd -time).txt"
Start-Transcript -path "$log.log" -append | Out-Null
Write-Host "Logging to $log"
$log
