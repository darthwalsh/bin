<#
.SYNOPSIS
Loop through multiple git repos and perform basic hygiene
.PARAMETER Prune
Display huge repos or repos that aren't mine
.PARAMETER OffMain
Look for branches off master/main branch or missing upstream
#>

param(
  [switch]$Prune = $false,
  [switch]$OffMain = $false
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

pushd (get-bin)
(git remote -v)[0] -match ':(\w+)' | Out-Null
$myGitHubUser = $Matches[1]
popd

$shortCodes = @{
  M = "modified"
  A = "added   "
  D = "deleted "
  R = "renamed "
  C = "copied  "
  U = "upmerged"
}
function TranlateShortStatus($line) {
  $code = $line.Substring(1, 1) 

  if ($shortCodes.Contains($code)) {
    $code = $shortCodes[$code]
  }

  if ($line.Substring(0, 2) -eq "??") {
    $code = "untracked"
  }
  
  "  $code $($line.Substring(2))"
}

function ForEachGit ($sb) {
  pushd
  gci -dir (Get-Code) | % {
    cd $_.FullName
    if (-not (Test-Path .git)) {
      return
    }

    & $sb
  }
  popd
}

if ($Prune) {
  $sizes = ForEachGit ( { 
    $kb = git count-objects -v | sls 'size-pack: (\d+)' | % { $_.Matches.Groups[1].Value }
    $notMine = git remote -v | sls '(fetch)' -raw | sls $myGitHubUser -notmatch -raw
  
    if ($kb -gt 1000 -or $notMine) {
      [PSCustomObject] @{
        kb = [int]$kb
        name = $pwd
        origins = $notMine
      }
    }
  }) | Sort-Object kb -Descending
  $sizes
  return
}

Write-Host "Fetching all repos" -ForegroundColor Blue -BackgroundColor White
ForEachGit ( { 
  $fetch = git fetch --quiet *>&1
  if ($fetch) {
    "$($_):"
    $fetch
  }
})

Write-Host "Looking for dirty files in repos" -ForegroundColor Blue -BackgroundColor White
$dirty = ForEachGit ( {
    $status = git status -s

    if ($status) {
      "$($_):"
      $status | % { TranlateShortStatus $_ }
    }
})
if ($dirty) {
  $dirty
  throw "Exiting script early: commit dirty files to some branch!"
}

Write-Host "`n`n`nLooking for branches ahead / behind origin" -ForegroundColor Blue -BackgroundColor White
ForEachGit ( {
    $status = git status
    $behind = $status | ? { $_ -Match "Your branch is behind" }
    if ($behind) {
      "$($_):"
      $behind
      if ($behind -Match "fast-forwarded") {
        git pull --quiet
      }
    }

    $ahead = $status | ? { $_ -Match "Your branch is ahead" }
    if ($ahead) {
      "$($_):"
      $ahead
      if ($ahead -Match "fast-forwarded") {
        git push
      }
    }
  })

if ($OffMain) {
  # Not on by default, because working on WIP branches is fine as long as they are pushed to github
  Write-Host "`n`n`nLooking for branches off master/main branch or missing upstream" -ForegroundColor Blue -BackgroundColor White
  ForEachGit ( {
      $branch = git branch
      $offMaster = -not ($branch -Contains "* master" -or $branch -Contains "* main") 
      $gone = (git status) -match "upstream is gone"

      if ($offMaster -or $gone) {
        "$($_):"

        if ($offMaster) {
          $branch | % { " " + $_ }
        }

        if ($gone) {
          "  $gone"
        }
      }
    })
}

Write-Host "`n`n`nLooking for local branches not in sync" -ForegroundColor Blue -BackgroundColor White
ForEachGit ( {
    $unpushedCommits = git log --branches --not --remotes --no-walk --oneline --decorate
    if ($unpushedCommits) {
      "$($_):"
      $unpushedCommits
    }
  })
