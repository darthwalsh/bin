<#
.SYNOPSIS
TODO summarize the version bumps in renovate PRs
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$RENOVATE_AUTHOR = [System.Text.RegularExpressions.Regex]::Escape('renovate[bot]')

filter parse {
    $msg = $_
    if ($msg.StartsWith('Configure Renovate')) { return }
    if ($msg.StartsWith('Migrate renovate config')) { return }

    # Exactly parse message, but ignore the security
    if ($msg -match '^Update (?:dependency )?(.+) to (\S+) (?:\[SECURITY\] )?\(#\d+\)$') {
        
        $version = $matches[2]
        return [PSCustomObject]@{
            name  = $matches[1]
            major = $version -notmatch '\.' # MAYBE use major
        }
    }
    throw "Unexpected message: $msg"
}


$changes = git log origin/$(Get-GitDefaultBranch.ps1) --author=$RENOVATE_AUTHOR --pretty=format:"%s" | parse
foreach ($g in $changes | ForEach-Object name | Group-Object | Sort-Object Count -Descending) {
    $amount = $g.Group.Count / $changes.Length

    "$($amount.ToString("P1").PadLeft(5)) $($g.Name)"
}
