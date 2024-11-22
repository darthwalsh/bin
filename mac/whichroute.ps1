<#
.SYNOPSIS
WHICH network interface used to connect using ROUTE
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$interface = route -n get 0.0.0.0 | awk '/interface: / {print $2}'

if ($interface.StartsWith("utun")) {
  "VPN: $interface"
} else {
  networksetup -listallhardwareports | rg $interface -C 1
}
