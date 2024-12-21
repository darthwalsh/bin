<#
.SYNOPSIS
Loops over TOP GitHub repos and DUMPs stub article
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$notes = '~/notes/MyNotes/Projects'
New-Item $notes -ItemType Directory -ErrorAction SilentlyContinue | out-null

foreach ($repo in gh repo list --source --json 'name,updatedAt,url' | ConvertFrom-JSON) {
  $file = Join-Path $notes "$($repo.name).md"
  if (Test-Path $file) { continue }
  if ($repo.updatedAt -lt ([datetime]::now + -2d * 365)) { continue }
  Set-Content $file "[github]($($repo.url))`n"
  $file
}
