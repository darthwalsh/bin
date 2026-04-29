<#
.SYNOPSIS
Show PR review comments for the current branch (or a given PR URL) #ai-slop
.DESCRIPTION
Prints the overall review summaries, then lists open (unresolved) inline
review threads with their diff context.
.PARAMETER Url
Optional GitHub PR URL. Defaults to the current branch's PR.
.OUTPUTS
Formatted review summary + open comment threads with diff hunks.
.EXAMPLE
PS> gh-pr-comments
.EXAMPLE
PS> gh-pr-comments https://github.com/org/repo/pull/42
#>

param(
    [Parameter(Mandatory = $false)]
    [string] $Url
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# ── helpers ────────────────────────────────────────────────────────────────────

function Invoke-Gh {
    param([string[]] $GhArgs)
    # Filter to the last line that looks like JSON (env-loader scripts may write to stdout first)
    $lines = gh @GhArgs
    $json = ($lines | Where-Object { $_ -match '^\s*[\[{]' } | Select-Object -Last 1)
    if (-not $json) { throw "No JSON output from: gh $($GhArgs -join ' ')" }
    $json | ConvertFrom-Json -Depth 20
}

function Invoke-GhGraphQL {
    param([string] $Owner, [string] $Repo, [int] $Number, [string] $Query)
    $lines = gh api graphql `
        --field "owner=$Owner" `
        --field "repo=$Repo" `
        --field "number=$Number" `
        --field "query=$Query"
    $json = ($lines | Where-Object { $_ -match '^\s*[\[{]' } | Select-Object -Last 1)
    if (-not $json) { throw "No JSON output from GraphQL query" }
    ($json | ConvertFrom-Json -Depth 30).data.repository.pullRequest
}

function Parse-PrUrl {
    param([string] $RawUrl)
    if ($RawUrl -match 'https?://[^/]+/([^/]+/[^/]+)/pull/(\d+)') {
        [pscustomobject]@{ Repo = $Matches[1]; Number = [int]$Matches[2] }
    } else {
        $null
    }
}

function Write-Header {
    param([string] $Text)
    $line = '─' * ($Text.Length + 4)
    ""
    "┌$line┐"
    "│  $Text  │"
    "└$line┘"
}

function Write-SectionHeader {
    param([string] $Text)
    ""
    $Host.UI.RawUI.ForegroundColor = 'Cyan'
    "── $Text"
    $Host.UI.RawUI.ForegroundColor = [System.ConsoleColor]::Gray
}

function Format-DiffHunk {
    param([string] $Hunk, [int] $ContextLines = 6)
    $allLines = $Hunk -split "`n"

    # Always keep the @@ header; truncate body to the last $ContextLines lines
    # so newly-added files don't dump hundreds of lines per comment.
    $headerLine = $allLines | Where-Object { $_ -match '^\s*@@' } | Select-Object -First 1
    $bodyLines  = $allLines | Where-Object { $_ -notmatch '^\s*@@' }
    $truncated  = $bodyLines.Count -gt $ContextLines
    $visibleBody = $bodyLines | Select-Object -Last $ContextLines

    foreach ($line in (@($headerLine) + @($visibleBody))) {
        if ($line -match '^\s*@@') {
            $Host.UI.RawUI.ForegroundColor = 'DarkCyan'
            "  $line"
        } elseif ($line.StartsWith('+')) {
            $Host.UI.RawUI.ForegroundColor = 'Green'
            "  $line"
        } elseif ($line.StartsWith('-')) {
            $Host.UI.RawUI.ForegroundColor = 'Red'
            "  $line"
        } else {
            $Host.UI.RawUI.ForegroundColor = 'Gray'
            "  $line"
        }
    }
    if ($truncated) {
        $Host.UI.RawUI.ForegroundColor = 'DarkGray'
        "  … ($($bodyLines.Count - $ContextLines) lines hidden)"
    }
    [Console]::ResetColor()
}

# ── resolve PR ─────────────────────────────────────────────────────────────────

if ($Url) {
    $parsed = Parse-PrUrl $Url
    if (-not $parsed) { throw "Could not parse PR URL: $Url" }
    $owner, $repoName = $parsed.Repo -split '/', 2
    $prNumber = $parsed.Number
} else {
    $viewData = Invoke-Gh @('pr', 'view', '--json', 'number,url,headRepositoryOwner,headRepository')
    $prNumber = $viewData.number
    $owner    = $viewData.headRepositoryOwner.login
    $repoName = $viewData.headRepository.name
    $Url      = $viewData.url
}

# ── fetch data ─────────────────────────────────────────────────────────────────

$reviewQuery = @'
query($owner: String!, $repo: String!, $number: Int!) {
  repository(owner: $owner, name: $repo) {
    pullRequest(number: $number) {
      title
      body
      reviews(first: 20) {
        nodes {
          author { login }
          body
          state
          createdAt
        }
      }
    }
  }
}
'@

$threadQuery = @'
query($owner: String!, $repo: String!, $number: Int!) {
  repository(owner: $owner, name: $repo) {
    pullRequest(number: $number) {
      reviewThreads(first: 100) {
        nodes {
          id
          isResolved
          isOutdated
          path
          line
          startLine
          comments(first: 20) {
            nodes {
              author { login }
              body
              createdAt
              diffHunk
            }
          }
        }
      }
    }
  }
}
'@

$reviewPr  = Invoke-GhGraphQL $owner $repoName $prNumber $reviewQuery
$threadPr  = Invoke-GhGraphQL $owner $repoName $prNumber $threadQuery

# ── print header ───────────────────────────────────────────────────────────────

Write-Header "PR #$prNumber · $($reviewPr.title)"
"  $Url"

# ── print review summaries ─────────────────────────────────────────────────────

$reviews = $reviewPr.reviews.nodes | Where-Object { $_.body.Trim() }
if ($reviews) {
    Write-SectionHeader "Review Summaries"
    foreach ($review in $reviews) {
        ""
        $stateIcon = switch ($review.state) {
            'APPROVED'           { '✅' }
            'CHANGES_REQUESTED'  { '🔴' }
            'COMMENTED'          { '💬' }
            default              { '📝' }
        }
        $Host.UI.RawUI.ForegroundColor = 'Yellow'
        "$stateIcon  $($review.author.login)  ($($review.state))  ·  $([datetime]$review.createdAt | Get-Date -Format 'yyyy-MM-dd')"
        [Console]::ResetColor()
        ""
        # Indent the body text
        foreach ($bodyLine in ($review.body -split "`n")) {
            "  $bodyLine"
        }
    }
}

# ── print open inline threads ──────────────────────────────────────────────────

$openThreads = $threadPr.reviewThreads.nodes |
    Where-Object { -not $_.isResolved -and -not $_.isOutdated }

if (-not $openThreads) {
    ""
    "✅  No open review threads."
} else {
    Write-SectionHeader "Open Threads  ($($openThreads.Count) unresolved)"

    $n = 0
    foreach ($thread in $openThreads) {
        $n++
        ""
        $Host.UI.RawUI.ForegroundColor = 'Magenta'
        "[$n]  $($thread.path)  (line $($thread.line))"
        [Console]::ResetColor()

        # diff hunk from the first comment
        $firstComment = $thread.comments.nodes[0]
        if ($firstComment.diffHunk) {
            Format-DiffHunk $firstComment.diffHunk
        }

        # all comments in the thread
        foreach ($comment in $thread.comments.nodes) {
            ""
            $Host.UI.RawUI.ForegroundColor = 'Yellow'
            "  ✏  $($comment.author.login)  ·  $([datetime]$comment.createdAt | Get-Date -Format 'yyyy-MM-dd')"
            [Console]::ResetColor()
            foreach ($bodyLine in ($comment.body -split "`n")) {
                "    $bodyLine"
            }
        }
    }
}

""
