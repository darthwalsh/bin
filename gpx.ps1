<#
.SYNOPSIS
Publish GPX from strava to OSM
.PARAMETER Pick
Optionally, choose from recent activities
#>

param(
  [switch]$Pick = $false
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

if ($Pick) {
  strava activities
  $id = Read-Host "Paste Activity ID"
} else {
  $id = strava activities --index 0 --quiet --per_page 1
}

$started = [DateTime]::Now
"Opening browser to download $id..."

Start-Process "https://www.strava.com/activities/$id/export_gpx"

# Put this delay after starding download
$details = strava activity $id -o json | ConvertFrom-Json

while (!($gpxFile = Get-ChildItem ~/Downloads/*.gpx | `
  Where-Object LastWriteTime -gt $started | `
  Select-Object -First 1)) {
  Start-Sleep 0.1
}

"Using OSM API to upload $gpxFile..."

Add-Type -TypeDefinition (Get-Content (Join-Path $PSScriptRoot "GpxUpload.cs") -Raw)

# Call a static method
$task = [GpxUpload]::Run($gpxFile.FullName, $details.start_date_local)
while (-not $task.AsyncWaitHandle.WaitOne(50)) { }
$gpxID = $task.GetAwaiter().GetResult()

Start-Process "https://www.openstreetmap.org/edit?gpx=$gpxID"
