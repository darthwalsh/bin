<#
.SYNOPSIS
Scans a folder for GitHub issue links and reports which are CLOSED.
#ai-slop need to refactor and test
.DESCRIPTION
Uses ripgrep to find GitHub issue URLs in code, then checks their status via the GitHub API.
Reports issues that have been closed so workarounds can be removed.

.EXAMPLE
scan4github ~/projects/my-repo
#>

param(
    [Parameter(Mandatory=$true)]
    [string] $Folder
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

throw "TODO #ai-slop"

$issuePattern = 'https://github\.com/([^/]+)/([^/]+)/issues/(\d+)' # TODO also match git.example.com

# Find all GitHub issue URLs using ripgrep
$matches = rg --no-heading --line-number --only-matching $issuePattern $Folder 2>$null

if (-not $matches) {
    Write-Host "No GitHub issue links found in $Folder" -ForegroundColor Green
    return
}

$issues = @{}

foreach ($match in $matches) {
    # Format: file:line:match
    if ($match -match '^(.+?):(\d+):(.+)$') {
        $file = $Matches[1]
        $line = $Matches[2]
        $url = $Matches[3]
        
        if ($url -match $issuePattern) {
            $owner = $Matches[1]
            $repo = $Matches[2]
            $number = $Matches[3]
            $key = "$owner/$repo#$number"
            
            if (-not $issues.ContainsKey($key)) {
                $issues[$key] = @{
                    Owner = $owner
                    Repo = $repo
                    Number = $number
                    Url = $url
                    Locations = @()
                }
            }
            $issues[$key].Locations += "${file}:${line}"
        }
    }
}

Write-Host "Found $($issues.Count) unique GitHub issue(s). Checking status..." -ForegroundColor Cyan$closedIssues = @()

foreach ($key in $issues.Keys) {
    $issue = $issues[$key]
    $apiUrl = "https://api.github.com/repos/$($issue.Owner)/$($issue.Repo)/issues/$($issue.Number)"
    
    try {
        $headers = @{ "User-Agent" = "scan4github" }
        if ($env:GITHUB_TOKEN) {
            $headers["Authorization"] = "token $env:GITHUB_TOKEN"
        }
        
        $response = Invoke-RestMethod -Uri $apiUrl -Headers $headers -ErrorAction Stop
        $state = $response.state
        
        if ($state -eq "closed") {
            $closedIssues += @{
                Key = $key
                Url = $issue.Url
                Title = $response.title
                ClosedAt = $response.closed_at
                Locations = $issue.Locations
            }
        }
    }
    catch {
        Write-Warning "Failed to check $key : $_"
    }
}

if ($closedIssues.Count -eq 0) {
    Write-Host "`nAll referenced issues are still open." -ForegroundColor Green
}
else {
    Write-Host "`n$($closedIssues.Count) CLOSED issue(s) found:" -ForegroundColor Yellow
    foreach ($closed in $closedIssues) {
        Write-Host "`n  $($closed.Key)" -ForegroundColor Red
        Write-Host "    $($closed.Title)"
        Write-Host "    Closed: $($closed.ClosedAt)"
        Write-Host "    URL: $($closed.Url)"
        Write-Host "    Referenced in:"
        foreach ($loc in $closed.Locations) {
            Write-Host "      - $loc"
        }
    }
    Write-Host ""
}
