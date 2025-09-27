<#
.SYNOPSIS
Checks login to CS department
.DESCRIPTION
Invoke with -NoProfile to avoid loading profile scripts
.PARAMETER install
Installs a scheduled task to run this script
#>

param(
    [switch]$install = $false
)

$PSNativeCommandUseErrorActionPreference = $true # Ensure failing commands crash
$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$bin = Split-Path -Parent $PSScriptRoot
$env:PATH += ";$bin" # When run -NoProfile PATH is missing

$log = start-log ".pingMuddLogs"

trap {
  fail-log $TaskName $log
  break
}

$TaskName = "_PingMuddMonthly"
if ($install) {
    $TaskDescription = "SSH to Mudd CS department and run 'pwd' command monthly to check login status."

    $Action = New-ScheduledTaskAction -Execute "pwsh.exe" -Argument "-NoProfile -WindowStyle Hidden -File `"$PSCommandPath`""
    # TODO windowstyle not working
    $Trigger = New-ScheduledTaskTrigger -Daily -DaysInterval 32 -At 9:00AM

    return Register-ScheduledTask -TaskName $TaskName -Trigger $Trigger -Action $Action -Description $TaskDescription -Force
}

ssh cwalsh@knuth.cs.hmc.edu -o BatchMode=yes pwd *>&1 >> $log
