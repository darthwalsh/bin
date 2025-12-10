<#
.SYNOPSIS
Run Docker baSH on recent docker image
.PARAMETER tag
Tag of the docker image to run
.PARAMETER entrypoint
If bash is not available, use sh
MAYBE could try to default to /bin/sh -c 'if [ -x /bin/bash ]; then /bin/bash; else /bin/sh; fi'
    -- but not sure how to handle @args
.EXAMPLE
PS> docker build . && dsh
#>

param(
  [string] $tag=$null,
  [string] $entrypoint="bash",
  [switch] $root=$false
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

if ($tag) {
  $id = $tag
} else {
  # Get both the tag name and image ID of the most recent image
  $imageInfo = docker images | Select-Object -Skip 1 -First 1
  $tag, $null, $id, $rest = -split $imageInfo
}
"Running $tag ($id)"

$envFile = "$tag.env"
$envArgs = if (Test-Path $envFile) { @("--env-file", $envFile) }

$rootArgs = if ($root) { @("--user", "root") }

docker run --rm -it --entrypoint $entrypoint @envArgs @rootArgs $id @args

# MAYBE add option to leave docker contaier running, allowing `docker cp`: 
# $container_name = $tag -replace '[^a-zA-Z0-9.-]', '-'
# if ($container_name -ne $tag) {
#   Write-Warning "Using safe name $container_name"
# }
# docker run --name $container_name --rm -it --entrypoint $entrypoint @envArgs $tag @args
