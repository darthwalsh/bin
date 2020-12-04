# OS-agnostic setup
# Install-Module posh-git -Scope CurrentUser --MAYBE NOT?
# Install-Module oh-my-posh -Scope CurrentUser --MAYBE_PRELEASE

function .. { cd .. }
function ... { cd ..\.. }
function .... { cd ..\..\.. }
function ..... { cd ..\..\..\.. }
function ...... { cd ..\..\..\..\.. }

function pushtmp {
  $tmp = Join-Path "Temp:" "DEL-$(Get-Date -Format "yyyyMMdd-HH-mm-ss.ff")"
  New-Item -ItemType Directory -Path $tmp | Out-Null
  Push-Location $tmp
}

Set-Alias py python3
Set-Alias python python3
$ENV:PYENV_SHELL = "pwsh"

function wh($ex) {
  gcm $ex -All
}

function export($s) {
  $n, $v = $s -split '='
  Set-Item "env:$n" $v
}

function Source-Anything($path) {
  $tempFile = (New-TemporaryFile).FullName + ".ps1"
  Copy-Item $path $tempFile
  . $tempFile
}

# root function? go to: git rev-parse --show-toplevel

# return # TODO
# some magic 'not interactive pw so skip the theme stuff???' and return

Set-PSReadlineOption -BellStyle Visual

New-Alias time Measure-Command
function timeit($func) { 0..3 | % { (time $func).TotalMilliseconds } }

If (Test-Path Alias:md) { Remove-Item Alias:md }
function md($dir) { mkdir -p $dir | out-null; cd $dir }

$env:PATH = @("~/OneDrive/bin", $env:PATH, ".") -join [IO.Path]::PathSeparator
# $env:PATH = "$env:PATH;."

if (gcm Set-PoshPrompt -ErrorAction SilentlyContinue) {
  Import-Module posh-git
  Set-PoshPrompt ~/OneDrive/Documents/PowerShell/.go-my-posh.json
  Import-Module posh-git
}
elseif (gcm Set-Theme -ErrorAction SilentlyContinue) {
  Import-Module posh-git
  Import-Module oh-my-posh
  Set-Theme carl
}
