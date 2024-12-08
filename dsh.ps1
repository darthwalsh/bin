<#
.SYNOPSIS
Run Docker baSH on recent docker image
.EXAMPLE
PS> docker build . && dsh
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# TODO this is not quite right, maybe add an optional param for tag
$last_tag = docker images | Select-Object -Skip 1 -First 1 | ForEach-Object { ($_ -split ' ')[0] }

"Running $last_tag"

$envFile = "$last_tag.env"
$envArgs = if (Test-Path $envFile) { @("--env-file", $envFile) } else { @() }
docker run --name $last_tag --rm -it --entrypoint /bin/bash @envArgs $last_tag @args
