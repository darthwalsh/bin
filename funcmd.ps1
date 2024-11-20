<#
.SYNOPSIS
For FUNCtion get MarkDown description
.DESCRIPTION
Makes a few assumptions:
function name is in the same directory
function has [comment-based help](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_comment_based_help?view=powershell-7.4)
.PARAMETER Name
Powershell function
#>

param(
    [Parameter(Mandatory=$true)]
    [string] $Name
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$h = Get-Help $Name # Might be nicer to use Get-Command but I want the default values
"### ``$Name`` - $($h.Synopsis)"
"[$Name.ps1]($Name.ps1)"
if ($h.parameters) {
  $h.parameters.parameter | ForEach-Object {
    if (-not $_.PSObject.Properties['description']) {
      Write-Warning "Help for $name is missing .PARAMETER for $($_.name)"
      return
    }
    $required = [bool]::Parse($_.required) # a string
    $default = if (!$required) { " = $($_.defaultValue ?? "<EMPTY>")" }
    "-  ``-$($_.name)$default`` $($_.description.Text)"
  }
  ""
}
if ($h.PSObject.Properties['description']) {
  $h.description.Text
}
