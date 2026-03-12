<#
.SYNOPSIS
AWS WHOami
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

aws sts get-caller-identity | ConvertFrom-Json | ForEach-Object Arn
