<#
.SYNOPSIS
Sets vscode as the default app for all extensions that other annoying apps (i.e. TextEdit and Xcode) are registered for
.DESCRIPTION
Needs duti from brew
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function getDefault($ext) {
  try {
    (duti -x $ext | Select-Object -first 1) 2> $null
  }
  catch {
    "UnknownApp"
  }
}

$dumpPath = Join-Path ([System.IO.Path]::GetTempPath()) 'lsregisterDump.txt'

if (!(Test-Path $dumpPath)) {
  # $lsregister = locate lsregister # locate not working on new macbook, so hardcode
  $lsregister = "/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister"
  & $lsregister -dump > $dumpPath
}

$dump = Get-Content $dumpPath

$tags = $dump | Select-String '^tags: +(.*)' | % { $_.Matches.Groups[1] -split ', ' | ? { $_[0] -eq '.'} }

$tags = $tags | Sort-Object | Get-Unique

$apps = @{}
foreach ($ext in $tags) {
  $app = getDefault $ext
  if (-not $app) {
    Write-Warning "No app for $ext"
    continue
  }
  if (-not $apps.ContainsKey($app)) {
    $apps[$app] = @()
  }
  $apps[$app] += $ext
}

foreach ($app in @("TextEdit", "Xcode", "Safari", "Visual Studio 2019 (2)")) {
  foreach ($ext in $apps[$app]) {
    duti -s com.microsoft.vscode $ext all
  }
}
