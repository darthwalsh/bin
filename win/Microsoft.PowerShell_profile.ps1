$parent = Join-Path $PSScriptRoot ".." # Support windowspowershell :(
. (Join-Path $parent "Microsoft.PowerShell_profile.ps1")


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
  $feat = Get-ExperimentalFeature -Name $name
  if ($feat.Enabled) { return }
  Write-Error "Please run 'Enable-ExperimentalFeature -Name $name' then restart pwsh"
}

EnsureExperimentalActive PSCommandNotFoundSuggestion
EnsureExperimentalActive PSFeedbackProvider
