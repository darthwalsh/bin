<#
.SYNOPSIS
Compress a JPG down aggressively
.DESCRIPTION
Requires ImageMagick to be installed:
- macOS: brew install imagemagick
- Windows: choco install imagemagick or winget install ImageMagick.ImageMagick
.PARAMETER File
Path to the JPG file to compress in-place
.EXAMPLE
PS> .\compress-jpg.ps1 foobar.jpg
#>

param(
    [Parameter(Mandatory=$true)]
    [string] $File
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

if ((Get-Item $File).Extension -ne ".jpg") {
    # TODO JPEG?
    throw "$File is not a JPG"
}

bak $File

$beforeSize = (Get-Item $File).Length

$width, $height = (dim $File) -split ' ' | ForEach-Object { [int]$_ }

# Only resize if image is larger than target (makes it idempotent)
$needsResize = $width -gt 1008 -or $height -gt 756

if ($needsResize) {
    # The ">" operator means "only resize if larger than"
    magick $File -resize "1008x756>" -quality 65 $File | Out-Null
} else {
    magick $File -quality 65 $File | Out-Null
}

$afterSize = (Get-Item $File).Length

function Format-FileSize {
    param([long]$Bytes)
    if ($Bytes -ge 1TB)  { return "{0:N2} TB" -f ($Bytes / 1TB) }
    if ($Bytes -ge 1GB)  { return "{0:N2} GB" -f ($Bytes / 1GB) }
    if ($Bytes -ge 1MB)  { return "{0:N2} MB" -f ($Bytes / 1MB) }
    if ($Bytes -ge 1KB)  { return "{0:N2} KB" -f ($Bytes / 1KB) }
    return "$Bytes B"
}

$beforeFormatted = Format-FileSize -Size $beforeSize
$afterFormatted = Format-FileSize -Size $afterSize
$reduction = [math]::Round((1 - ($afterSize / $beforeSize)) * 100, 1)

$resizeInfo = if ($needsResize) { "resized to max 1008×756" } else { "already at target size" }
Write-Host "Compressed $File (q65, $resizeInfo)" -ForegroundColor Green
Write-Host "-$beforeFormatted" -ForegroundColor DarkRed
Write-Host "+$afterFormatted" -ForegroundColor DarkGreen
Write-Host "($reduction% reduction)" -ForegroundColor Blue
