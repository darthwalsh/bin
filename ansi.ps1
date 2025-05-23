<#
.SYNOPSIS
Gets ANSI colorized version of text
.PARAMETER Text
The text to colorize
.PARAMETER R
The red component of the color (0-255)
.PARAMETER G
The green component of the color (0-255)
.PARAMETER B
The blue component of the color (0-255)
.EXAMPLE
PS> "$(ansi PEACH 0xFF 0x80 0x80) and $(ansi LIME 0 0xFF 0)"
#>

param(
    [Parameter(Mandatory=$true)] [string] $Text,
    [Parameter(Mandatory=$true)] [int] $R,
    [Parameter(Mandatory=$true)] [int] $G,
    [Parameter(Mandatory=$true)] [int] $B
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

foreach($i in @($R, $G, $B)) {
    if ($i -lt 0 -or $i -gt 255) {
        throw "Color values must be between 0 and 255"
    }
}

# See https://stackoverflow.com/a/74601731/771768
$ANSI = [char]27
"$ANSI[38;2;$R;$G;$($B)m$Text$ANSI[0m"

