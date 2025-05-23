<#
.SYNOPSIS
Gets ANSI colorized version of some metric
.PARAMETER Text
The text to colorize
.PARAMETER Factor
< 0.5  is green
= 2    is red
> 2.75 is magenta
linear scale in between
.EXAMPLE
PS> foreach ($v in 0..14) { $v /= 4; metric-ansi $v $v }
#>

param(
  [Parameter(Mandatory = $true)] [string] $Text,
  [Parameter(Mandatory = $true)] [double] $Factor
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Convert-HSVToRGB([float]$H, [float]$S, [float]$V) {
  # https://chatgpt.com/share/682ff0f7-d2b4-8011-a19d-f6f184ed2ba8
  if ($S -eq 0) {
    $R = [math]::Round($V * 255)
    return $R, $R, $R
  }

  $H = $H % 360
  $H /= 60
  $i = [math]::Floor($H)
  $f = $H - $i
  $p = $V * (1 - $S)
  $q = $V * (1 - $S * $f)
  $t = $V * (1 - $S * (1 - $f))

  switch ($i) {
    0 { $R = $V; $G = $t; $B = $p }
    1 { $R = $q; $G = $V; $B = $p }
    2 { $R = $p; $G = $V; $B = $t }
    3 { $R = $p; $G = $q; $B = $V }
    4 { $R = $t; $G = $p; $B = $V }
    5 { $R = $V; $G = $p; $B = $q }
  }

  ($R * 255), ($G * 255), ($B * 255)
}

<#
Factor=0.5 => 120 GREEN
Factor=2.0 =>   0 RED

a * 0.5 + b = 120
a * 2.0 + b = 0

a = -120 / 1.5  = -80
b = 80 * 2.0 = 160
#>
$hue = -80 * $Factor + 160

$hue = if ($hue -lt -60) { 
  300
} elseif ($hue -lt 0) {
  $hue + 360
} elseif ($hue -lt 120) {
  $hue 
} else { 
  120
}

$color = Convert-HSVToRGB $hue 1 1
ansi $Text @color
