<#
.SYNOPSIS
Create a GitHub Pages and set up CloudFlare DNS to point to it
.DESCRIPTION
Depends on cfcli from https://www.npmjs.com/package/cloudflare-cli
Depends on gh from https://cli.github.com/
.PARAMETER Label
String like "myproj" that is the subdomain for your cloudflare account
#>

param(
  [Parameter(Mandatory = $true)]
  [string] $Label
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$reg = '^[a-z0-9-]+$'
if (-not ($Label -match $reg)) {
  throw "label doesn't match /$reg/"
}

$records = cfcli find $Label -f json | ConvertFrom-Json
if (!$records) {
  $remote = git ls-remote --get-url

  if (-not ($remote -match "github.com.(\w+)")) {
    throw "$remote isn't a github URL?"
  }

  $owner = $Matches[1]

  cfcli -t CNAME add $Label "$owner.github.io"
  $records = cfcli find $Label -f json | ConvertFrom-Json
}

$defaultBranch = (git symbolic-ref refs/remotes/origin/HEAD) -replace 'refs/remotes/origin/', ''
$body = @{
  source = @{
    branch = $defaultBranch
    path   = "/"
  }
}

# Little strange to need two calls; submitted feedback to GitHub
$body | ConvertTo-Json | gh api /repos/:owner/:repo/pages --input - --header "Accept:application/vnd.github.switcheroo-preview+json"

$body.cname = $($records.name)
$body | ConvertTo-Json | gh api -X PUT /repos/:owner/:repo/pages --input - --header "Accept:application/vnd.github.switcheroo-preview+json"
