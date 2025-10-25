<#
.SYNOPSIS
Output all console colors
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# Rainbow order: Red -> Orange -> Yellow -> Green -> Cyan -> Blue -> Indigo/Violet -> Neutrals
$rainbowOrder = @(
  'Red', 'DarkRed',           # Red spectrum
  'DarkYellow', 'Yellow',     # Orange/Yellow spectrum
  'Green', 'DarkGreen',       # Green spectrum
  'Cyan', 'DarkCyan',         # Cyan spectrum
  'Blue', 'DarkBlue',         # Blue spectrum
  'Magenta', 'DarkMagenta',   # Violet spectrum
  'Gray', 'DarkGray', 'White', 'Black'  # Neutrals
)

$rainbowOrder | ForEach-Object {
  Write-Host "$_ " -ForegroundColor $_ -NoNewline
  if ($_ -eq 'Black') { 
    Write-Host "<- (did you see Black)" -ForegroundColor Black -BackgroundColor White -NoNewline
  }
}


