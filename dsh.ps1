<#
.SYNOPSIS
Run Docker baSH on recent docker image
.DESCRIPTION
Detects if the image is amd64 but the host is arm64, and adds --platform linux/amd64
.PARAMETER tag
Tag of the docker image to run
.PARAMETER entrypoint
If bash is not available, use sh
MAYBE could try to default to /bin/sh -c 'if [ -x /bin/bash ]; then /bin/bash; else /bin/sh; fi'
    -- but not sure how to handle @args
.PARAMETER root
Run as root user
.EXAMPLE
PS> docker build . && dsh
#>

[CmdletBinding()]
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

# Auto-detect: if the image is amd64 but this host is arm64, Docker needs --platform to run under emulation.
$imageArch = docker image inspect --format '{{.Architecture}}' $id
$hostIsArm = [System.Runtime.InteropServices.RuntimeInformation]::ProcessArchitecture -eq [System.Runtime.InteropServices.Architecture]::Arm64
$amdArgs = if ($imageArch -eq 'amd64' -and $hostIsArm) { @("--platform", "linux/amd64") }
$allArgs = @("run", "--rm", "-it", "--entrypoint", $entrypoint) + $envArgs + $rootArgs + $amdArgs + @($id) + $args
Write-Verbose "docker $allArgs"
docker @allArgs

# MAYBE add option to leave docker contaier running, allowing `docker cp`: 
# $container_name = $tag -replace '[^a-zA-Z0-9.-]', '-'
# if ($container_name -ne $tag) {
#   Write-Warning "Using safe name $container_name"
# }
# docker run --name $container_name --rm -it --entrypoint $entrypoint @envArgs $tag @args
