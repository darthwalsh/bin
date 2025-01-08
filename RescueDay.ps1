<#
.SYNOPSIS
get data for RescueTime day
.PARAMETER File
path to JSON file of API call for interval/activity
.EXAMPLE
rescueday 2023-05-20.json | format-table

[TimeSpan]::FromSeconds((rescueday 2023-05-20.json | % duration | measure -Property TotalSeconds -Sum | % Sum)).ToString()

gci *.json | % { $_.BaseName + " " + [TimeSpan]::FromSeconds((rescueday $_ | % duration | measure -Property TotalSeconds -Sum | % Sum)) } | code -
#>

param(
    [Parameter(Mandatory=$true)]
    [string] $File
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$data = Get-Content $File -raw | ConvertFrom-Json

$rows = foreach ($row in $data.rows) {
  $rowData = [PSCustomObject]@{}
  for ($i = 0; $i -lt $row.Count; $i++) {
    # $hashTable[$data.row_headers[$i]] = $row[$i]

    $header = $data.row_headers[$i]
    $datum = $row[$i]
    if ($header -eq 'Date') {
      $datum = [datetime]::Parse($datum)
    }
    if ($header -eq 'Time Spent (seconds)') { 
      $header = 'duration'
      $datum = [TimeSpan]::FromSeconds($datum)
    }
    if ($header -eq 'Number of People') {
      continue
    }
    $rowData | Add-Member -NotePropertyName $header -NotePropertyValue $datum
  }
  $rowData
}

$rows
if (!$rows) {
  [PSCustomObject]@{
    Date         = [datetime]::Parse((gi $File | % BaseName))
    duration     = [TimeSpan]::FromSeconds(0)
    Activity     = ''
    Category     = ''
    Productivity = 0
  }
}
