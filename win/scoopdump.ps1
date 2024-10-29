<#
.SYNOPSIS
Dump installed scoop apps to current github repo
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# Redirect stream 6 to suppress Write-Host https://stackoverflow.com/a/50937428/771768
$buckets = scoop list  6> $null | Group-Object Source -AsHashTable -AsString

$expected = @('main', 'extras')

$outfile = New-TemporaryFile
function printBucket($b) {
    "$($b.ToUpper()) BUCKET" >> $outfile
    $buckets[$b].Name >> $outfile
    "" >> $outfile
}

foreach ($b in $expected) {
    printBucket $b
}

foreach ($b in $buckets.Keys | Sort-Object) {
    if ($expected -notcontains $b) {
        printBucket $b
    }
}

$winBin = Join-Path (Get-Bin) win
$scoopFile = Join-Path $winBin "scoopfile-$($ENV:COMPUTERNAME).txt"
Move-Item -Force $outfile $scoopFile
"Written to $scoopFile"
