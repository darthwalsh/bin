<#
.SYNOPSIS
Run Docker baSH on recent docker image
.PARAMETER tag
Tag of the docker image to run
.EXAMPLE
PS> docker build . && dsh
#>

param(
  [string] $tag=$null,
  [string] $entrypoint="/bin/bash"
)

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

if (!$tag) {
  # TODO this is not quite right, as a cached build won't be the most recent
  $tag = docker images | Select-Object -Skip 1 -First 1 | ForEach-Object { ($_ -split ' ')[0] }
}

"Running $tag"

$envFile = "$tag.env"
$envArgs = if (Test-Path $envFile) { @("--env-file", $envFile) } else { @() }

docker run --rm -it --entrypoint $entrypoint @envArgs $tag @args

# MAYBE add option to leave docker contaier running, allowing `docker cp`: 
# $container_name = $tag -replace '[^a-zA-Z0-9.-]', '-'
# if ($container_name -ne $tag) {
#   Write-Warning "Using safe name $container_name"
# }
# docker run --name $container_name --rm -it --entrypoint $entrypoint @envArgs $tag @args
