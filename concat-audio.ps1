#!/usr/bin/env pwsh
<#
.SYNOPSIS
    #ai-slop Concatenate multiple audio files into one using ffmpeg.
.DESCRIPTION
    Takes multiple audio files and concatenates them in order using ffmpeg's concat demuxer.
    Files are copied without re-encoding, so they should have the same codec/sample rate.
.PARAMETER Files
    Audio files to concatenate, in order.
.PARAMETER Output
    Output file path. Defaults to "combined.<extension>" based on first input file.
.EXAMPLE
    concat-audio file1.wav file2.wav file3.wav
.EXAMPLE
    concat-audio *.m4a -Output merged.m4a
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory, Position = 0, ValueFromRemainingArguments)]
    [string[]]$Files,

    [Parameter()]
    [string]$Output
)

$script:ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

if ($Files.Count -lt 2) {
    throw "Need at least 2 files to concatenate"
}

$resolvedFiles = $Files | ForEach-Object {
    $resolved = Resolve-Path $_ -ErrorAction Stop
    $resolved.Path
}

if (-not $Output) {
    $ext = [System.IO.Path]::GetExtension($resolvedFiles[0])
    $Output = "combined$ext"
}

if (Test-Path $Output) {
    throw "Output file already exists: $Output"
}

# ffmpeg concat demuxer requires a text file listing inputs, not CLI args
$concatList = New-TemporaryFile
try {
    $resolvedFiles | ForEach-Object {
        "file '$_'"
    } | Set-Content -Path $concatList.FullName

    Write-Host "Concatenating $($resolvedFiles.Count) files -> $Output" -ForegroundColor Cyan
    $resolvedFiles | ForEach-Object { Write-Host "  $_" -ForegroundColor DarkGray }

    $concatPath = Convert-Path $concatList.FullName
    ffmpeg -f concat -safe 0 -i $concatPath -c copy $Output

    $result = Get-Item $Output
    Write-Host "Created: $($result.FullName) ($([math]::Round($result.Length / 1MB, 1)) MB)" -ForegroundColor Green
}
finally {
    Remove-Item $concatList.FullName -ErrorAction SilentlyContinue
}
