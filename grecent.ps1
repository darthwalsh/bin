<#
.SYNOPSIS
Git RECENT: interactive picker that selects a "since" file and prints all files modified at or after it.
.DESCRIPTION
Shows an interactive list of all uncommitted changed files (tracked modifications + untracked), sorted
by LastWriteTime descending. Uses fzf to pick the cutoff file.

Outputs the selected file and every file that is newer-or-equal in modification time — useful for
piping a focused, time-bounded slice of changes into another tool (diff, copy, review, etc.).
.OUTPUTS
One path per line: the selected file followed by all files with LastWriteTime >= the selected file.
.EXAMPLE
PS> git add (grecent)
#>


$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$allFiles = gfiles

if (-not $allFiles) {
  throw "No changed files found."
}

$fileInfos = $allFiles | Where-Object { Test-Path -LiteralPath $_ } | ForEach-Object {
  [pscustomobject]@{
    OrigPath      = $_
    LastWriteTime = (Get-Item -Force -LiteralPath $_).LastWriteTime # MAYBE fix this to work when in a subdir
  }
} | Sort-Object LastWriteTime -Descending

$FORMAT = 'yyyy-MM-dd HH:mm'
try {
  $selected = $fileInfos | ForEach-Object { "$($_.LastWriteTime.ToString($FORMAT)) $($_.OrigPath)" } | fzf --no-sort --layout=reverse
} catch [System.Management.Automation.NativeCommandExitException] {
  Write-Warning "No user selection made, exiting."
  exit 0
}
if (-not $selected) { 
  Write-Warning "No user selection made, exiting."
  exit 0 
}

$y, $t, $_path = $selected -split ' '
$cutoff = [datetime]::ParseExact("$y $t", $FORMAT, $null)

$fileInfos | Where-Object LastWriteTime -ge $cutoff | ForEach-Object OrigPath
