<#
.SYNOPSIS
Turns off monitors
.DESCRIPTION
Base on https://gist.github.com/EugeneLoy/150044d04b08e35d09e164c864e78da7
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

 (Add-Type '[DllImport("user32.dll")] public static extern int PostMessage(int hWnd, int hMsg, int wParam, int lParam);' -Name a -Pas)::PostMessage(-1, 0x0112, 0xF170, 2)
