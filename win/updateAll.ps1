<#
Important! Run this script using powershell.exe to ensure that pwsh can be updated
Run this script to update all scoop/choco/npm packages

Set up Task Scheduler to run this script:
Name _WakeNightly, Run whether user is logged in or not
Sunday Morning 7am
C:\WINDOWS\System32\WindowsPowerShell\v1.0\powershell.exe <THIS-PATH>\updateAll.ps1
Wake computer to run when on A/C

Note: If Scheduled task is not running, check that the PC is waking up:
Power Options > Edit Plan Settings > Change advanced power settings > Sleep > Allow wake timer > Enabled
#> 

# $script:ErrorActionPreference = "Stop" TODO need to figure out how to handle updates that fail. Write to system mail? 
Set-StrictMode -Version Latest

$file = "update_{0:yyyy_MM_dd}_{0:HH_mm_ss}.txt" -f (Get-Date)
$log = join-path "$HOME\Downloads" $file
Start-Transcript -path "$log.log" -append
"Logging to $log"

$PSCommandPath >> $log
echo "" >> $log

# Check if any pwsh.exe is running
$pwsh = Get-WmiObject Win32_Process -Filter "name = 'pwsh.exe'" | Select-Object CommandLine
if ($pwsh) {
    echo "pwsh.exe is running, this will cause problems with scoop upgrade..." >> $log
    echo $pwsh >> $log

    # MAYBE would be cool to kill all pwsh.exe processes, but this is dangerous
    <# MAYBE can we print the pwsh.exe CWD? But it's complicated...
      - https://microsoft.public.windows.powershell.narkive.com/RptsRNs4/getting-the-working-directory-for-a-process
      - https://stackoverflow.com/q/20576834/771768 handle.exe works, but seems like it should print all open dir handles?
    #>
}

function update(
    [string]$cmd,
    [parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Passthrough
) {
    $installed = Get-Command $cmd -ErrorAction SilentlyContinue
    echo "" >> $log
    if (-not $installed) { echo "'$cmd' not installed" >> $log; return }
    & $cmd @Passthrough *>&1 >> $log
    echo "" >> $log
    echo "$cmd update done!"  >> $log
    echo "" >> $log
}

update scoop update *
update scoop cleanup --cache *
update choco upgrade all --no-progress
update npm update -g
update code --update-extensions

echo "" >> $log
echo "All updates done!" >> $log

pwsh -c scoopdump
pwsh -c wingetdump

function checkReboot($path) {
  $req = Test-Path $path
  "$($req)   $path"  >> $log
  if ($req) {
    Restart-Computer
  }
}
echo "" >> $log
echo "Pending reboot required?" >> $log
checkReboot 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
checkReboot 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending'
checkReboot 'HKLM:\CurrentControlSet\Control\Session Manager'

Stop-Transcript
