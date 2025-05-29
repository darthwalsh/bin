<#
.SYNOPSIS
Writes env vars to .env file
.DESCRIPTION
I have a lot of environment scripts, that set some required variables for pytest to run.
Useful for vscode to load PYTHONPATH:
https://code.visualstudio.com/docs/python/environments#_use-of-the-pythonpath-variable
.EXAMPLE
PS> write-env PYTHONPATH GITHUB_TOKEN
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

if (Test-Path .env) {
  bak .env | Out-Null
}

$args | ForEach-Object {
  $v = [System.Environment]::GetEnvironmentVariable($_) 
  "$_=$v" 
} | Out-File -FilePath .env -Encoding utf8


<#
Maybe something magic like the below could work, but needs to ensure if you run it a second time it doesn't wipe .env
(i.e. If the script sets PYTHONPATH, so it would get written to .env, but if you run it again, it shouldn't delete that existing PYTHONPATH.)
Could work to parse the .env file and also keep any variables that ever made it into there?

$oldEnvVars = Get-ChildItem Env: | ForEach-Object {
  [PSCustomObject]@{
    Name  = $_.Name
    Value = $_.Value
  }
}

function callback {
  $newEnvVars = Get-ChildItem Env: | ForEach-Object {
    [PSCustomObject]@{
      Name  = $_.Name
      Value = $_.Value
    }
  }

  $differences = Compare-Object -ReferenceObject $oldEnvVars -DifferenceObject $newEnvVars -Property Name, Value

  $differences 
}

callback


#>
