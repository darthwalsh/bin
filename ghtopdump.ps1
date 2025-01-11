<#
.SYNOPSIS
Loops over TOP GitHub repos and DUMPs stub article
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$notes = '~/notes/MyNotes/Projects'
New-Item $notes -ItemType Directory -ErrorAction SilentlyContinue | out-null

foreach ($repo in gh repo list --source --limit 100 --json 'name,owner,updatedAt,url' | ConvertFrom-JSON) {
  if ($repo.name.StartsWith("CSS")) { continue }

  $file = Join-Path $notes "$($repo.name).md"
  if (Test-Path $file) { continue }

  $oldestInclude = [datetime]::now - [TimeSpan]::FromDays(365 * 4)
  if ($repo.updatedAt -lt $oldestInclude) { continue }

  $lastCommitDate = [datetime](gh api "repos/$($repo.owner.login)/$($repo.name)/commits" --jq '.[0].commit.author.date')
  if ($lastCommitDate -lt $oldestInclude) { continue }
  Set-Content $file "[github]($($repo.url))`n"
  $file
}
