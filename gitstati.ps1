$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

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

Write-Host "Updating all repos" -ForegroundColor Blue -BackgroundColor White
ForEachGit ( { git remote -v; git fetch; })

Write-Host "Looking for dirty files in repos" -ForegroundColor Blue -BackgroundColor White
ForEachGit ( {
    $status = git status -s

    if ($status) {
      echo "$($_):"
      $status | % { TranlateShortStatus $_ }
    }
  })

Write-Host "`n`n`nLooking for branches ahead / behind origin" -ForegroundColor Blue -BackgroundColor White
ForEachGit ( {
    $status = git status
    $behind = $status | ? { $_ -Match "Your branch is behind" }
    if ($behind) {
      echo "$($_):"
      $behind
      if ($behind -Match "fast-forwarded") {
        git pull
      }
    }

    $ahead = $status | ? { $_ -Match "Your branch is ahead" }
    if ($ahead) {
      echo "$($_):"
      $ahead
      if ($ahead -Match "fast-forwarded") {
        git push
      }
    }
  })

Write-Host "`n`n`nLooking for branches off master/main branch or missing upstream" -ForegroundColor Blue -BackgroundColor White
ForEachGit ( {
    $branch = git branch
    $offMaster = -not ($branch -Contains "* master" -or $branch -Contains "* main") 
    $gone = (git status) -match "upstream is gone"

    if ($offMaster -or $gone) {
      echo "$($_):"

      if ($offMaster) {
        $branch | % { " " + $_ }
      }

      if ($gone) {
        "  $gone"
      }
    }
  })

