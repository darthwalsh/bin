param(
    [Parameter(Mandatory=$true)]
    [string] $File
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# BUG for some reason, this ends up printing a warning
#   The command "..." was not found, but does exist in the current location.
# That only prints when running the PS1 direction, not from the pwsh binary.
$existing = Get-Command -Name $File -ErrorAction SilentlyContinue
if ($existing) {
  $existing
  throw "Existing " + $existing.Source
}

$ext = [IO.Path]::GetExtension($File)
if ($ext -eq ".ps1") {
}
elseif (!$ext) {
  $File += ".ps1"
} else {
  throw "File shouldn't have extension $ext"
}

$File = join-path $PSScriptRoot $File

if (!(Test-Path $File)) {
  Set-Content $File '<#
.SYNOPSIS
Runs a command
.DESCRIPTION
More description
.PARAMETER File
Param 1
.INPUTS
Pipe something?
.OUTPUTS
Prints something fancy?
.EXAMPLE
PS> .\Script.ps1 foobar
#>

param(
    [Parameter(Mandatory=$true)]
    [string] $File
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

'
}

code $File
