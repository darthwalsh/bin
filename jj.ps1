<#
.SYNOPSIS
Outputs Jira Json to text editor
.PARAMETER ID
Jira ID
#>

param(
    [Parameter(Mandatory=$true)]
    [string] $Id
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

jira view $Id -t json | code -
