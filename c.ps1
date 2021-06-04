<#
.SYNOPSIS
Open vscode, based on arg path, cmd, or with stdin
.PARAMETER FileOrScript
If path exists, open code on path. Otherwise 
.INPUTS
Pipe something?
.OUTPUTS
Prints something fancy?
.EXAMPLE
PS> .\Script.ps1 foobar
#>

param(
    [string] $FileOrScript
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

if (!$FileOrScript) {<#
   8        0.003 echo "a" "b"
  9         11.861 echo "a" "b" | code -
  10        0.070 echo "a" "b" | code - &
  11        0.016 gal &
  12        0.004 GEt-Job
  13        0.002 GEt-Job
  14        0.009 gal -def Receive-Job
  15        0.026 rcjb 3
  16        0.001 rcjb 1
  17        0.002 GEt-Job
  18        0.002 GEt-Job
  19        0.028 gal -def Start-ThreadJob
  20        0.522 $j = Start-ThreadJob { echo a b | code - }
  21        0.011 $j
  22        0.002 $j | Receive-Job
  23        0.001 $j | Receive-Job
  24        0.002 Start-ThreadJob { echo a b | code - }  | Receive-Job
  25        4.441 Receive-Job
  26        0.013 get-job
  27        0.003 get-job 6
  28        5.307 echo a b | code -

  #>
}

throw "TODO"
