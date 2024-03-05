# OS-agnostic setup. Manually run:
# Install-Module Pester -Scope CurrentUser
# Install-Module posh-git -Scope CurrentUser
# Install-Module powershell-yaml -Scope CurrentUser
# Install-Module PowerShellForGitHub -Scope CurrentUser

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
  # TODO this doesn't work if value has '=' in it
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

if (gcm gh -all -ErrorAction SilentlyContinue) {
  Invoke-Expression -Command $(gh completion -s powershell | Out-String)
}

New-Alias time Measure-Command
function timeit($func) { 0..3 | % { (time $func).TotalMilliseconds } }

If (Test-Path Alias:md) { Remove-Item Alias:md }
function md($dir) { mkdir -p $dir | out-null; cd $dir }

function PrependPATH($s) {
  $s = (Resolve-Path $s).Path # https://github.com/ansible/ansible-lint/issues/2688#issuecomment-1944316451
  if (($ENV:PATH -split [IO.Path]::PathSeparator) -contains $s) { return }
  $env:PATH = $s + [IO.Path]::PathSeparator + $env:PATH
}
function AppendPATH($s) {
  $s = (Resolve-Path $s).Path
  if (($ENV:PATH -split [IO.Path]::PathSeparator) -contains $s) { return }
  $env:PATH = $env:PATH + [IO.Path]::PathSeparator + $s
}

PrependPATH $PSScriptRoot
AppendPATH "." # Useful, but don't cd into untrusted folders!

if (gcm Set-PoshPrompt -ErrorAction SilentlyContinue) {
  Write-Warning "Stop using pwsh module! https://ohmyposh.dev/docs/migrating"
}

if (gcm oh-my-posh -ErrorAction SilentlyContinue) {
  $env:VIRTUAL_ENV_DISABLE_PROMPT = "yes" # Skip venv prompt, because custom prompt sets it

  Import-Module posh-git
  oh-my-posh init pwsh --config (Join-Path $PSScriptRoot .go-my-posh.yaml) | Invoke-Expression
}
