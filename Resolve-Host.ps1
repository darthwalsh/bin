<#
.SYNOPSIS
Gets host-name information
.PARAMETER HostName
Host name or IP address
.INPUTS
Can accept HostName from pipeline
.OUTPUTS
0, 1, or many System.Net.IPAddress
.EXAMPLE
PS> .\Script.ps1 foobar
#>

param(
  [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
  [string] $HostName
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

try {
  [System.Net.Dns]::GetHostAddresses($HostName)
}
catch [System.Net.Sockets.SocketException] { 
  
}
