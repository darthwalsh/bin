<#
.SYNOPSIS
Approve and Merge one or more PRs
.PARAMETER PRs
PR numbers, URLs, or branch names. Default: current branch's PR.
.EXAMPLE
PS> ghmerge 1234 5678
.EXAMPLE
PS> ghmerge https://github.com/org/repo/pull/1234
#>
param(
    [string[]]$PRs = @("")
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

foreach ($pr in $PRs) {
    gh pr review $pr --approve
    gh pr merge $pr --auto --squash
}
