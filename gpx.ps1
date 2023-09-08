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

Add-Type -TypeDefinition (Get-Content (Join-Path $PSScriptRoot "GpxUpload.cs") -Raw)

if ($Pick) {
  $u, $p = [GpxUpload]::OsmAuth() -split -split ":"
  $secpasswd = ConvertTo-SecureString $p -AsPlainText -Force
  $credential = New-Object System.Management.Automation.PSCredential ($u, $secpasswd)
  $traces = Invoke-RestMethod "https://api.openstreetmap.org/api/0.6/user/gpx_files" -Authentication Basic -Credential $credential

  $regex = [regex]"\d{4}-\d{2}-\d{2}"
  $dates = @{}
  $traces.osm.gpx_file.description | % { $v = $regex.Matches($_); if ($v) { $dates[$v.Value] = 1 } }

  foreach ($line in strava activities) {
    $v = $regex.Matches($line)
    if (!$v) { $line; continue }
    if (!$dates[$v.Value]) { $line }
  }
  $id = Read-Host "Paste Activity ID"
} else {
  $id = strava activities --index 0 --quiet --per_page 1
}

$started = [DateTime]::Now
"Opening browser to download $id..."

Start-Process "https://www.strava.com/activities/$id/export_gpx"

# Put this delay after starting download
$details = strava activity $id -o json | ConvertFrom-Json

while (!($gpxFile = Get-ChildItem ~/Downloads/*.gpx | `
  Where-Object LastWriteTime -gt $started | `
  Select-Object -First 1)) {
  Start-Sleep 0.1
}

"Using OSM API to upload $gpxFile..."


# Call a static method
$task = [GpxUpload]::Run($gpxFile.FullName, $details.start_date_local)
while (-not $task.AsyncWaitHandle.WaitOne(50)) { }
$gpxID = $task.GetAwaiter().GetResult()

Start-Process "https://www.openstreetmap.org/edit?gpx=$gpxID"
