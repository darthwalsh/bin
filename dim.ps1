<#
.SYNOPSIS
get DIMensions of an image
.DESCRIPTION
Depends on imagemagick installed
.PARAMETER File
Image path
.OUTPUTS
"Width Height" as a single line
#>

param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
    [string] $File
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

magick identify -format "%w %h" $File
