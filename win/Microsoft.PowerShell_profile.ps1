$parent = Join-Path $PSScriptRoot ".." # Support windowspowershell :(
. (Join-Path $parent "Microsoft.PowerShell_profile.ps1")

# MAYBE not a good idea... see bin/apps/pwsh.encoding.md - Fixes fixes pipx output
$OutputEncoding = [Console]::InputEncoding = [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding

function assoc { cmd /c assoc $args }
function ftype { cmd /c ftype $args }

function AddPathIfExists($dir) {
  if (Test-Path $dir) { prependPATH $dir }
}

AddPathIfExists "C:\Windows\Microsoft.NET\Framework\v4.0.30319\"

function AddVSProgramFilesPath($dir) {
  AddPathIfExists [IO.Path]::Combine(${Env:ProgramFiles(x86)}, "Microsoft Visual Studio", $dir)
}

AddVSProgramFilesPath "2017\Enterprise\MSBuild\15.0\Bin"
AddVSProgramFilesPath "2017\Enterprise\Common7\IDE"
AddVSProgramFilesPath "2019\Enterprise\MSBuild\Current\Bin"
AddVSProgramFilesPath "2019\Enterprise\Common7\IDE"

AddPathIfExists "${Env:ProgramFiles(x86)}\Microsoft SDKs\Windows\v10.0A\bin\NETFX 4.7 Tools"
AddPathIfExists "${Env:ProgramFiles(x86)}\Microsoft SDKs\Windows\v10.0A\bin\NETFX 4.8 Tools"

AddPathIfExists $PSScriptRoot

function EnsureExperimentalActive($name) {
  if ($PSEdition -eq "Desktop") { return } # HACK Not supported in Windows PowerShell
  # Better to use Feature Detection `if (gcm Get-ExperimentalFeature)` but it takes 100ms on powershell??
  $feat = Get-ExperimentalFeature -Name $name
  if ($feat.Enabled) { return }
  Write-Error "Please run 'Enable-ExperimentalFeature -Name $name' then restart pwsh"
}

# TODO now mainstream: https://learn.microsoft.com/en-us/powershell/scripting/learn/experimental-features?view=powershell-7.5#pscommandnotfoundsuggestion EnsureExperimentalActive PSCommandNotFoundSuggestion
EnsureExperimentalActive PSFeedbackProvider

AddPathIfExists ~\.local\bin  # Used for pipx, uv, etc.
