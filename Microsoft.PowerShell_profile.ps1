# OS-agnostic setup
# Install-Module posh-git -Scope CurrentUser
# Install-Module oh-my-posh -Scope CurrentUser

# Default handler excludes lines like /password/ -- Instead use bash pattern of excluding lines with leading space
# https://github.com/PowerShell/PSReadLine/blob/bc485e0208d5dbf44c3d92a1dec9d466c41afc36/PSReadLine/History.cs#L116
Set-PSReadlineOption -AddToHistoryHandler { param ($line) -not $line.StartsWith(' ') }
Set-PSReadlineOption -MaximumHistoryCount 32767

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

if (Get-Command python.exe -errorAction SilentlyContinue) {
  # Windows pyenv doesn't shim `python3`
  Set-Alias py python
  Set-Alias python3 python
} else {
  Set-Alias py python3
  Set-Alias python python3
}

function ipy {
  py -m IPython @args
}

$ENV:PYENV_SHELL = "pwsh"

function wh($ex) {
  $cmds = gcm $ex -All
  foreach ($cmd in $cmds) {
    $cmd
    if ($cmd.CommandType -ne 'Alias') { continue }

    wh $cmd.ResolvedCommand
  }
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

# MAYBE some magic 'not interactive pw so skip the theme stuff???' and return

Set-PSReadlineOption -BellStyle Visual
Invoke-Expression -Command $(gh completion -s powershell | Out-String)

New-Alias time Measure-Command
function timeit($func) { 0..3 | % { (time $func).TotalMilliseconds } }

If (Test-Path Alias:md) { Remove-Item Alias:md }
function md($dir) { mkdir -p $dir | out-null; cd $dir }

$env:PATH = @($PSScriptRoot, $env:PATH, ".") -join [IO.Path]::PathSeparator

if (gcm Set-PoshPrompt -ErrorAction SilentlyContinue) {
  $env:VIRTUAL_ENV_DISABLE_PROMPT = "yes"
  
  Import-Module posh-git
  Set-PoshPrompt (Join-Path $PSScriptRoot .go-my-posh.yaml)
}
