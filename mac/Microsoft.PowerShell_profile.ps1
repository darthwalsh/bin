. (Join-Path $PSScriptRoot ".." "Microsoft.PowerShell_profile.ps1")

$ENV:PATH = "~/.pyenv/shims:$($PSScriptRoot):~/Library/Python/3.8/bin:$ENV:PATH"

export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
export HOMEBREW_AUTOREMOVE=1

New-Alias svs serverless

$ENV:NVM_DIR = "$HOME/.nvm"
function nvm() {
  $quotedArgs = ($args | ForEach-Object { "'$_'" }) -join ' '
  
  zsh -c "source /usr/local/opt/nvm/nvm.sh && nvm $quotedArgs && echo __PATH_AFTER__`$PATH" | Tee-Object -Variable zsh_output | Where-Object { -not ($_ -match "^__PATH_AFTER__") }

  $path_after = $zsh_output | Select-String "^__PATH_AFTER__(.+)"
  if ($path_after) {
    $ENV:PATH = $path_after.Matches.Groups[1].Value
  }
}
# nvm --version | Out-Null # Load your current nvm path
