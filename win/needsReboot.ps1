"CurrentVersion\Component Based Servicing\RebootPending"
Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending" -EA Ignore

""
"CurrentVersion\WindowsUpdate\Auto Update\RebootRequired"
Get-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired" -EA Ignore

""
"HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager"
Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -Name PendingFileRenameOperations -EA Ignore

"util.DetermineIfRebootPending()"
$util = [wmiclass]"\\.\root\ccm\clientsdk:CCM_ClientUtilities"
$util.DetermineIfRebootPending()

