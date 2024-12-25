<#
.SYNOPSIS
Dump ENVironment variables for the machine and user
.DESCRIPTION
Adds newlines after ; to make PATH easy to read
#>


$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$outfile = New-TemporaryFile

$groups = @{}
function processEnv($group) {
  $env = [System.Environment]::GetEnvironmentVariables($group)
  $sorted = [ordered]@{}
  foreach($key in $env.Keys | Sort-Object) {
    $sorted[$key] = $env[$key] -replace ";", ";`n"
  }
  $groups[$group] = $sorted
}

processEnv "Machine"
processEnv "User"
# No need to save Process env var; that's not interesting

$groups | ConvertTo-Yaml >> $outfile

$winBin = Join-Path (Get-Bin) win
$envdumpFile = Join-Path $winBin "envdump-$($ENV:COMPUTERNAME).yaml"
Move-Item -Force $outfile $envdumpFile
"Written to $envdumpFile"
