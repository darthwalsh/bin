<#
.SYNOPSIS
Outputs git commands to run to set up new machine, based on git folders under current directory
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

foreach ($old in (Get-ChildItem -Directory)) {
  if (!(Test-Path (Join-Path $old .git))) {
    continue
  }

  $new = $old -replace '/Users/walshca_1', '/Users/walshca'

  "git clone $(git -C $old config --get remote.origin.url) $new --recursive"
  foreach ($remote in (git -C $old remote)) {
    $remote = $remote.Trim()
    if ($remote -eq "origin") {
      continue
    }
    "git -C $new remote add $remote $(git -C $old config --get remote.$remote.url)"
  }
  foreach ($ig in git -C $old status --ignored --porcelain) {
    if ($ig.StartsWith(' M ')) {
      Write-Warning "Modified tracked file: $ig"
    }
    $ig -replace '!! ',"ff $($old.Name)/" 
  }

  foreach ($conf in @('my.jira.component', 'my.jira.project')) {
    $confOld = git -C $old config --get $conf
    if ($confOld) {
      "git -C $new config $conf `"$confOld`""
    }
  }
}
