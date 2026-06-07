<#
.SYNOPSIS
For hatch projects, alias commands to hatch run
#>


$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

Remove-Alias py -ErrorAction SilentlyContinue
function global:py { 
  hatch run python $args
}
function global:pytest {
  hatch test $args
}
function global:ruff {
  hatch run ruff $args
}
Write-Host "BTW, py and pytest are wrappers!" -ForegroundColor Yellow
