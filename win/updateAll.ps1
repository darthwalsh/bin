$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$file = "update_{0:yyyy_MM_dd}_{0:HH_mm_ss}.txt" -f (Get-Date)
$log = join-path "$HOME\Downloads" $file

$PSCommandPath >> $log
echo "" >> $log

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

update "scoop.cmd" "update" "*"
update "scoop.cmd" "cleanup" "--cache" "*"
update "choco" "upgrade" "all" "--no-progress"
update "npm" "update" "-g"

echo "" >> $log
echo "All updates done!" >> $log

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

