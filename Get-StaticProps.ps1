<#
.SYNOPSIS
Gets all static props on some type
.PARAMETER Class
Type or name
.EXAMPLE
Get-StaticProps IO.Path
#>

Param (
  [Parameter(Mandatory)]
  [type]$Class
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

Get-Member -InputObject $Class -Static -MemberType Property |
    Select-Object -ExpandProperty Name | 
    ForEach-Object { [PSCustomObject]@{ Name=$_; Value=$Class::$_ } }
