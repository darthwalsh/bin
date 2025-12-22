<#
.SYNOPSIS
gets the FullName from the input
.PARAMETER File
the file or folder
.EXAMPLE
PS> gi wiki.py | % fullname
PS> gi wiki.py | fn
PS> fn wiki.py
#>

param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
    [System.IO.FileSystemInfo] $File
)

process {
  $script:ErrorActionPreference = "Stop"
  Set-StrictMode -Version Latest

  $File.FullName
}
