<#
.SYNOPSIS
Print a random quotation
.DESCRIPTION
Uses glow for markdown rendering
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$all = sls '~' ~/notes/MyNotes/Quotations.md
$random = $all | Get-Random
$random.Line | glow --width 0
