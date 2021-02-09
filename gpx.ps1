<#
.SYNOPSIS
Publish GPX from strava to OSM
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

strava stats

dotnet run --project (Join-Path (Get-Code) RunTheGlobe) -- gpx @args

# Run `dotnet publish -c Release` first
# $dll = Join-Path (Get-Code) RunTheGlobe\bin\Release\net5.0\RunTheGlobe.dll
# dotnet $dll gpx

