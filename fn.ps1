<#
.SYNOPSIS
gets the FullName from the input
.PARAMETER File
FileSystemInfo file or folder, or ExternalScriptInfo from Get-Command
.EXAMPLE
PS> gi wiki.py | % fullname
PS> gi wiki.py | fn
PS> fn wiki.py
#>

param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
    [object] $File
)

process {
  $script:ErrorActionPreference = "Stop"
  Set-StrictMode -Version Latest

  if ($File.PSObject.Properties['Source']) {
    $File.Source
  } elseif ($File.PSObject.Properties['FullName']) {
    $File.FullName
  } else {
    throw "Input object does not have Source or FullName property"
  }
}
