<#
.SYNOPSIS
Git commit empty BUMP; git push
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

git commit --allow-empty -m 'bump'; git push
