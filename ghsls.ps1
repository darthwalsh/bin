<#
.SYNOPSIS
Search for my code in github 
.DESCRIPTION
Forwards args to gh search code:
      --extension string   Filter on file extension
      --filename string    Filter on filename
      --language string    Filter results by language
  -L, --limit int          Maximum number of code results to fetch (default 30)
      --match strings      Restrict search to file contents or file path: {file|path}
  -R, --repo strings       Filter on repository
  -w, --web                Open the search query in the web browser
.EXAMPLE
PS> ghsls MonkeyRunner --language python -w
PS> ghsls --extension md --repo darthwalsh/AutoNonogram
#>

$script:ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$orig_env_var = $ENV:GH_HOST # MAYBE xplat with [env]./apps/env.md), like with_env(GH_HOST $null) { gh ... } "context manager?"
$ENV:GH_HOST = $null

try {
  gh search code --owner=darthwalsh @args
} finally {
  $ENV:GH_HOST = $orig_env_var
}
