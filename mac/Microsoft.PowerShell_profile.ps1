. (Join-Path $PSScriptRoot ".." "Microsoft.PowerShell_profile.ps1")

PrependPATH "~/.local/bin"
PrependPATH "~/go/bin"
PrependPATH $PSScriptRoot
if (Test-Path ~/.pyenv) { prependPATH ~/.pyenv/shims }

export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
export HOMEBREW_NO_AUTO_UPDATE=1 # Using brew autoupdate so skip interactively updating

Set-Alias ee /bin/echo

function nvm() {
  write-warning "nvm doesn't support pwsh, just use npm from brew"
}
# nvm --version | Out-Null # Load your current nvm path

function exec() {
  Write-Warning "exec will kill current shell, ignoring"
}

<# By default fzf will use the current shell for preview commands, which for my pwsh is slow launching the profile.
So we force it to use zsh. #>
function fzf {
  $input | /usr/bin/env SHELL="/bin/zsh" /opt/homebrew/bin/fzf @Args
}
