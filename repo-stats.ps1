<#
.SYNOPSIS
github REPOsitory STATS
.DESCRIPTION
TODO look at scoring system in https://github.com/ganesshkumar/obsidian-plugins-stats-ui/discussions/52
(Maybe it would be best to just highlight the top-3 most concerning metrics, and let the user decide how to rank between them?)

Looked for online tool that did this: https://chatgpt.com/share/67ecb8c6-5814-8011-9be3-6393938a1a2f 
One web app was broken: https://github.com/vesoft-inc/github-statistics/issues/70
Seems to only have their projects: https://docs.linuxfoundation.org/lfx/insights

Before taking a dependency on a project, it would be nice to get a "maintained score" that's a little more advanced than just GitHub stars.
MAYBE The ChatGPT link has 10 suggestions, but I think the most feasible to add on are:

1. Commit/Releases: frequency/recency
2. Pull Requests: getting reviewed
3. Issues: are maintainers replying to issues?
4. Contributor: unique count (including issues/discussion)
5. License: Permissive / copyleft / proprietary (maybe 3p dependencies too?)
.PARAMETER Repository
URL or github description, or get the current repo
.EXAMPLE
PS> repo-stats EzioDEVio/gh-repo-stats
PS> repo-stats https://github.com/EzioDEVio/gh-repo-stats
🌟5 🍴1 🔓2 👀5 🔖main 📦false 👥2 📌52 EzioDEVio/gh-repo-stats
#>

param(
  [string] $Repository = ''
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

if (!$Repository) {
  $Repository = git config --get remote.origin.url
}
$owner, $repo, $extra = if ($Repository -match 'github.com.([^/]+)/([^./]+)') {
  $matches[1..2]
} else {
  $Repository -split '/'
}
if (!$repo -or $extra) {
  throw "Invalid repository: $Repository :: $owner, $repo, $extra"
}

# Workaround for https://github.com/EzioDEVio/gh-repo-stats/issues/4 run local. Switch to gh repo-stats eventually
$text = ~/code/gh-repo-stats/gh-repo-stats -owner $owner -repo $repo
$summary = foreach ($line in $text) {
  # An emoji is not a C# char (UTF-16 code unit) but one grapheme https://stackoverflow.com/a/77622888/771768
  $c = [Globalization.StringInfo]::GetTextElementEnumerator($line) | Select-Object -first 1
  $isEmoji = $c.Length -eq 2
  if ($isEmoji) {
    $end = $line -split ' ' | Select-Object -last 1
    "$c$end"
  }
} 
($summary + @("$owner/$repo")) -join ' '
