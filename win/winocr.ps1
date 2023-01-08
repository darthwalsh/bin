<#
.SYNOPSIS
Captures current clipboard to OCR and returns the text.
.DESCRIPTION
Windows-only. Needs to run in powershell.exe IIRC
Depends on https://github.com/TobiasPSP/PsOcr
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

Add-Type -Assembly PresentationCore
$img = [Windows.Clipboard]::GetImage()
if ($img -eq $null) {
  Write-Host "No image in clipboard!" -ForegroundColor "Red"
  Exit
}
$fcb = new-object Windows.Media.Imaging.FormatConvertedBitmap($img, [Windows.Media.PixelFormats]::Rgb24, $null, 0)

$path = "{0}\Clipboard-{1}.png" -f (Join-Path (Join-Path $Env:USERPROFILE OneDrive) TODO), ((Get-Date -f s) -replace '[-T:]', '_') # TODO move to temp?

$stream = [IO.File]::Open($path, "OpenOrCreate")
$encoder = New-Object Windows.Media.Imaging.PngBitmapEncoder
$encoder.Frames.Add([Windows.Media.Imaging.BitmapFrame]::Create($fcb))
$encoder.Save($stream)
$stream.Dispose()

# https://github.com/TobiasPSP/PsOcr
$text = Convert-PsoImageToText $path | % Text
$text

Write-Host "Copying to clipboard" -ForegroundColor Blue
$text | Set-Clipboard

remove-item $path
