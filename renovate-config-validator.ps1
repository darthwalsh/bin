<#
.SYNOPSIS
runs NPM renovate-config-validator
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# https://docs.renovatebot.com/config-validation/
npx --yes --package renovate renovate-config-validator --strict @args
