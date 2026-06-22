#!/usr/bin/env pwsh
# Returns a prompt indicator string based on age of ~/.config/yest-completed.txt.
# Intended to be called as: $env:YEST_STATUS = & "$PSScriptRoot/Get-YestStatus.ps1"

$yestFile = "$HOME/.config/yest-completed.txt"
if (-not (Test-Path $yestFile)) {
  "❌❌❌ $HOME/.config/yest-completed.txt file not found!!!"
  return
}

if ((Get-Date).DayOfWeek -in @('Saturday', 'Sunday')) {
  return ""
}

# test: (Get-Item ~/.config/yest-completed.txt).LastWriteTime = (Get-Date).AddHours(-50)
$ageHours = ((Get-Date) - (Get-Item $yestFile).LastWriteTime).TotalHours
if ($ageHours -gt 48) {
  "⬅️⬅️⬅️📅📅📅 YEST YEST YEST "
} elseif ($ageHours -gt 24) {
  "⬅️📅 yest "
} else {
  ""
}
