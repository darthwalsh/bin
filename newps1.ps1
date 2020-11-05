param(
    [Parameter(Mandatory=$true)]
    [string] $File
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

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
