<#
.SYNOPSIS
WIP Export all git history
.DESCRIPTION
Outputs fields: datetime, num_files, file_types, lines_added, lines_deleted, description, url

Not lines_changed because git doesn't have that concept
.PARAMETER TODO
Param 1
#>

[CmdletBinding()]
param(
  # [Parameter(Mandatory=$true)]
  [string] $Start = "",
  [string] $End = "",
  [string] $Repo = ""
)

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
# MAYBE user local repo instead of github API
function readRepo($Repo) {
  # TODO hardcode {owner} so this works with both orgs and users
  $commits = ghApi "/repos/{owner}/$Repo/commits" --jq '.[].sha'
  # Write-Verbose -Message ($commits -join ",")

  if ($commits.Length -ge 25) { throw "not implemented pagination" }
  # TODO --paginate

  [array]::reverse($commits)
  foreach ($c in $commits) {
    if (getDB $c) {
      continue # TODO how do we use invariant to break out of foreach?
    }

    $details = ghApi "/repos/{owner}/$Repo/commits/$c" | ConvertFrom-Json
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

# MAYBE for org repo, probably best to loop over PRs and the merge commits?
function scanPR {
  # Run this from a PR in your account so {owner} is your username

  $prs = ghApi /search/issues --method GET -F 'q=author:{owner} -user:{owner} is:pr' --paginate | ConvertFrom-Json
  # TODO $prs.items = $prs.items | Select-Object -first 2

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

    [ordered]@{
      datetime      = $o.date
      num_files     = $o.files.Length
      file_types    = $fileTypes.Keys -join ' '
      lines_added   = $o.additions
      lines_deleted = $o.deletions
      url           = $o.url
      description   = $o.message
    }
  }
}

function makeCSV {
  Get-ChildItem (Join-Path ~ .hist-for-git) | CSVentry | Sort-Object { [datetime]$_.datetime } | ConvertTo-Csv
}

# readRepo 'PullMention'
readRepo 'AutoNonogram'

# scanPR

makeCSV

<#


TODO server-side-filter on forks?


gh repo list --json name,owner --jq '.[] | .owner.login + \"/\" + .name'
darthwalsh/FireSocket
darthwalsh/Austerity
darthwalsh/my-repo
darthwalsh/CromulentWordle


IDEAS v2:
MAYBE commits off the default branch: Iter through parents, halt once known history?

gh api /search/commits --method GET -F 'q=author:darthwalsh user:Pash-Project' --jq '.items[] | .url'
- TODO pagination

Issues created:
gh api /search/issues --method GET -F 'q=author:darthwalsh -user:darthwalsh -is:pr' --jq '.items[] | .url'

Issue comments?

v3:
- search bitbucket / OR! move all repos to github / OR use local repos

#>
