<#
.SYNOPSIS
List all uncommitted changed files (tracked modifications + untracked).
.OUTPUTS
File path strings
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$trackedFiles = git diff --name-only
$untrackedFiles = git ls-files --others --exclude-standard
$trackedFiles + $untrackedFiles
