<#
.SYNOPSIS
Starts a pomodoro timer
.PARAMETER min
Minutes
#>

param(
  [Parameter(Mandatory = $true)]
  [int] $min
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

pomodoro -c "$($min)m"
while (1) { 
  osascript -e beep
  sleep 5
}
