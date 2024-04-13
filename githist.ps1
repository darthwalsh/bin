<#
.SYNOPSIS
WIP Export all git history
.DESCRIPTION
Outputs fields: datetime, num_files, file_types, lines_added, lines_deleted, description, url

Not lines_changed because git doesn't have that concept

Set env var GITHIST_SINGLE to take only the commit title
#>

[CmdletBinding()]

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$FILTER_NAME = "Carl Walsh"

New-Item (Join-Path ~ .hist-for-git) -Force -ItemType Directory | Out-Null
function dbPath($sha) {
  Join-Path ~ .hist-for-git "$sha.json"
}

function getDB($sha) {
  if (-not (Test-Path (dbPath $sha))) {
    return $null
  }

  get-content (dbPath $sha) | ConvertFrom-Json
}

function setDB($sha, $data) {
  ConvertTo-Json $data | Set-Content (dbPath $sha)
}

function ghApi {
  Write-Verbose -Message "gh api `"$($args -join '" "')`"" -Verbose
  gh api $args
}

<#
Invariant: if a commit exists in DB, then all commits in parent history have been loaded
This means we need to write commits in earliest-first order.
#>
# COULD user local repo instead of github API, but this works without cloning everything
function readRepo($ownerSlashRepo) {
  try {
    $commits = ghApi "/repos/$ownerSlashRepo/commits" --paginate --jq '.[].sha'
  } catch {
    Write-Warning -Message "$_"
    return
  }

  # Write-Verbose -Message ($commits -join ",")

  [array]::reverse($commits)
  foreach ($c in $commits) {
    if (getDB $c) {
      continue # COULD use invariant to break out of foreach but paginating all commits is fast enough
    }

    $details = ghApi "/repos/$ownerSlashRepo/commits/$c" | ConvertFrom-Json
    # Write-Verbose -Message $details

    $data = @{
      name      = $details.commit.author.name
      date      = $details.commit.author.date
      message   = $details.commit.message
      url       = $details.html_url
      files     = @($details.files | Select-Object -ExpandProperty filename)
      additions = $details.stats.additions
      deletions = $details.stats.deletions
    }

    setDB $c $data
  }
}
# run with i.e. readRepo 'darthwalsh/my-repo'

# MAYBE for org repo, probably best to loop over PRs and the merge commits?
function scanPR {
  # Run this from a PR in your account so {owner} is your username

  $prs = ghApi /search/issues --method GET -F 'q=author:{owner} -user:{owner} is:pr' --paginate | ConvertFrom-Json

  foreach ($pr in $prs.items) {
    if (getDB $pr.node_id) {
      continue
    }

    $pullUrl = $pr.pull_request.url
    $pull = ghApi $pullUrl | ConvertFrom-Json
    $files = ghApi "$pullUrl/files" | ConvertFrom-Json

    $message = if ($pull.merged) { '' } else { 'UNMERGED '}
    $message += $pull.title
    if ($pull.body) {
      $message += "`n`n$pull.body"
    }

    $data = @{
      name      = $FILTER_NAME
      date      = $pull.created_at
      message   = $message
      url       = $pull.html_url
      files     = @($files | Select-Object -ExpandProperty filename)
      additions = $pull.additions
      deletions = $pull.deletions
    }

    setDB $pr.node_id $data
  }
}


function CSVentry([Parameter(ValueFromPipeline)] $path) {
  process {
    Write-Verbose $path
    $o = Get-Content $path | ConvertFrom-Json
    
    if ($o.name -ne $FILTER_NAME) { return }

    $fileTypes = @{}
    foreach ($f in $o.files) {
      $ext = [System.IO.Path]::GetExtension($f)
      $withoutDot = if ($ext) { $ext.Substring(1) } else { $f }
      $fileTypes[$withoutDot] = 1
    }

    $desc = if ($env:GITHIST_SINGLE) { $o.message -split "`n" | select -first 1 } else { $o.message }

    [ordered]@{
      datetime      = $o.date
      num_files     = $o.files.Length
      file_types    = $fileTypes.Keys -join ' '
      lines_added   = $o.additions
      lines_deleted = $o.deletions
      url           = $o.url
      description   = $desc
    }
  }
}

function makeCSV {
  Get-ChildItem (Join-Path ~ .hist-for-git) | CSVentry | Sort-Object { [datetime]$_.datetime } | ConvertTo-Csv
}

function readAllPersonalRepo {
  $lim = 100
  # --source for no fork
  $repos = gh repo list --source --limit $lim --json 'name,owner' --jq '.[] | .owner.login + \"/\" + .name'
  if ($repos.Length -eq $lim) {
    throw "needs pagination or a bigger limit!?"
  }

  foreach ($s in $repos) {
    readRepo $s
  }
}


# scanPR

readAllPersonalRepo

$csvPath = Join-Path ([System.IO.Path]::GetTempPath()) "githist-$(Get-Date -Format "yyyy-MM-dd").csv"
makeCSV > $csvPath
$csvPath

<#
IDEAS v2:
MAYBE commits off the default branch: Iter through parents, halt once known history?

gh api /search/commits --method GET -F 'q=author:darthwalsh user:Pash-Project' --jq '.items[] | .url'
- TODO pagination

Issues created:
gh api /search/issues --method GET -F 'q=author:darthwalsh -user:darthwalsh -is:pr' --jq '.items[] | .url'

Issues I commented on?

v3:
- search bitbucket / OR! move all repos to github / OR use local repos

#>
