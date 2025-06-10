<#
.SYNOPSIS
RipGrep Global for all sibling paths
.DESCRIPTION
When run in ~/code/bin, searching 
.PARAMETER search
The search term to look for
.PARAMETER path
The path to search in, relative to the all sibling directories
.EXAMPLE
PS> 
#>

param(
    [Parameter(Mandatory=$true)]
    [string] $search,
    [Parameter(Mandatory=$true)]
    [string] $path,
    [parameter(ValueFromRemainingArguments = $true)]
    [string[]] $args
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$parent = Split-Path (Get-Location) -Parent
$star = Join-Path $parent '*' $path
Write-Verbose "Searching for '$search' in '$star' with args: $args"

rg $search $star @args
