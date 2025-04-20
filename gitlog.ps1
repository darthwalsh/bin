<#
.SYNOPSIS
GIT LOG from current branch back to default branch
.DESCRIPTION
No indent, vs. default git og
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

git --no-pager log HEAD --not origin/$(Get-GitDefaultBranch) --format=%B%n --reverse
