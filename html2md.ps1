<#
.SYNOPSIS
Convert HTML from stdin to markdown
.DESCRIPTION
Assumes defuddle is installed: npm install -g defuddle
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$input | ForEach-Object -Begin { "<!DOCTYPE html><html><body>" } -Process { $_ } -End { "</body></html>" } | defuddle parse /dev/stdin --markdown
