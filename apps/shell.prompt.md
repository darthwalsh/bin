Used oh-my-zsh for a bit when using built-in zsh on MacBook.
- [ ] Get my config rc file #macbook 

For a while, was using a custom powershell prompt:

```pwsh
#requires -Version 2 -Modules posh-git

function Write-Theme {
  param(
    [bool]
    $lastCommandFailed,
    [string]
    $with
  )

  # Writes the postfixes to the prompt with color
  $promtSymbolColor = $lastCommandFailed ? $sl.Colors.WithForegroundColor : $sl.Colors.PromptSymbolColor
  $prompt += Write-Prompt $sl.PromptSymbols.PromptIndicator -ForegroundColor $promtSymbolColor
  $prompt += Write-Prompt ' '

  # TODO check the python virtual environment
  if (Test-VirtualEnv) {
    $prompt += Write-Prompt ("(" + $(Get-VirtualEnvName) + ") ")
  }

  # Writes the 'drive' portion i.e. pwd
  $drive = $pwd.Path.Replace($HOME, $sl.PromptSymbols.HomeSymbol)
  $drive = $drive.Replace('C:\code\', '')
  $prompt += Write-Prompt $drive -ForegroundColor $sl.Colors.DriveForegroundColor
  $prompt += Write-Prompt ' '

  $status = Get-VCSStatus
  if ($status) {
    $branchColor = $status.Branch -in $knownMainBranch ? $sl.Colors.PromptSymbolColor : $sl.Colors.WithForegroundColor
    $prompt += Write-Prompt $status.Branch -ForegroundColor $branchColor
    $prompt += Write-Prompt ' '
    if ($status.Working.Length -gt 0) {
      $prompt += Write-Prompt $sl.PromptSymbols.GitDirtyIndicator -ForegroundColor $sl.Colors.GitDefaultColor
      $prompt += Write-Prompt ' '
    }
  }

  $promptSymbol = (Test-Administrator) ? '% ' : '$ ' # TODO?

  $prompt += Write-Prompt $promptSymbol
  $prompt
}

$knownMainBranch = @('master', 'main', 'develop')

$sl = $global:ThemeSettings #local settings
$sl.PromptSymbols.PromptIndicator = [char]::ConvertFromUtf32(0x279C)
$sl.Colors.PromptSymbolColor = [ConsoleColor]::Green
$sl.Colors.DriveForegroundColor = [ConsoleColor]::Cyan
$sl.Colors.WithForegroundColor = [ConsoleColor]::Red
$sl.PromptSymbols.GitDirtyIndicator = [char]::ConvertFromUtf32(10007)
$sl.Colors.GitDefaultColor = [ConsoleColor]::Yellow


```

Finally I switched to [oh-my-posh](https://ohmyposh.dev/) -- I like that it is more cross-platform now, not tied to [[pwsh]].
See config [here](../.go-my-posh.yaml). 
