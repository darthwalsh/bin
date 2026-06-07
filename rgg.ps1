<#
.SYNOPSIS
RipGrep Global for all sibling paths
.DESCRIPTION
When run in ~/code/bin, searches under ~/code 
.PARAMETER search
The ripgrep glob pattern to search
.PARAMETER path
The path to search in, relative to the all sibling directories
.EXAMPLE
PS> 
#>

[CmdletBinding()]
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

$path = $path -replace '^\./', ''  # Powershell tab completion adds ./ if present
$parent = Split-Path (Get-Location) -Parent
Write-Verbose "rg $search -g $path $parent $args --hidden"
rg $search -g $path $parent @args --hidden
