<#
.SYNOPSIS
Query for all non-default branches in all repos
#>

# TODO would be nice to find associated pull requests, and/or filter out branches with PRs


$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

Write-Host "Querying for branches" -ForegroundColor Blue
$json = gh api graphql -f query='
{
  viewer {
    repositories(first: 100, ownerAffiliations: OWNER, orderBy: {field: PUSHED_AT, direction: DESC}) {
      nodes {
        name
        defaultBranchRef { name }
        refs(first: 20, refPrefix: "refs/heads/", orderBy: {field: TAG_COMMIT_DATE, direction: DESC}) {
          nodes {
            name
            target {
              ... on Commit {
                committedDate
                author { user { login } }
              }
            }
          }
        }
      }
    }
  }
}'

$User = gh api user --jq .login

$data = $json | ConvertFrom-Json
$rows = foreach ($repo in $data.data.viewer.repositories.nodes) {
  $default = if ($repo.defaultBranchRef) { $repo.defaultBranchRef.name } else { $null }

  $branches = @($repo.refs.nodes | Where-Object {
      $_.name -ne $default -and
      $_.target -and
      $_.target.author -and
      $_.target.author.user -and
      $_.target.author.user.login -eq $User
    })

  foreach ($b in $branches) {
    [pscustomobject]@{
      Committed  = $b.target.committedDate | ymd
      URL = "https://github.com/$User/$($repo.name)/tree/$($b.name)"
    }
  }
}

$limit = 15
$rows | Sort-Object Committed -Descending | Select-Object -First $limit | Format-Table -AutoSize

If ($limit -lt $rows.Length) {
  Write-Warning "Showing $limit of $($rows.Length) branches"
} 
