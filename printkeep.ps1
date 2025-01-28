<#
.SYNOPSIS
Outputs nice content of Google Keep notes
.PARAMETER File
Filename. If starts with year, not printed
.PARAMETER Creation
Prints creation date in YAML front matter
#>

param(
    [Parameter(Mandatory=$true)]
    [string] $File,
    [switch] $Creation = $false
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$item = Get-Item $File
$content = Get-Content -Raw $File

$base = $item.BaseName

if ($content -match "aliases:`n  - `"(.*)`"`n") {
  "## " + $matches[1]
} elseif (-not ($base -match '^20\d\d-\d\d-\d\dT')) {
  "## " + $base
} else {
  "`n---"
}

if ($content.StartsWith("---")) {
  $content = $content -split '---' | Select-Object -skip 2
}

if ($Creation) {
  "---"
  "created: $($item.CreationTime.ToString('yyyy-MM-dd'))"
  "---"
}
# "## $($item.CreationTime.ToString('yyyy-MM-dd'))"

$content.Trim()
"`n---`n"

# NOT NEEDED: just symlink Assets/ into vault
# # Find link like ![[18cc06d7b0f.a8b6c61df584a88d.png]] and copy attachment
# foreach ($match in [regex]::Matches($content, '!\[\[(.*?)\]\]')) {
#   $noteAttachments = "~/notes/MyNotes/KeepAttachments"
#   mkdir -p $noteAttachments
#   $attachment = $match.Groups[1].Value
#   Copy-Item -Force (Join-Path $item.DirectoryName Assets $attachment) "$noteAttachments/$attachment"
# }
