---
aliases:
  - oh-my-posh
---
## zsh
Used oh-my-zsh for a bit when using built-in zsh on MacBook. `.zshrc` was:
```zsh
# Path to your oh-my-zsh installation.
export ZSH="/Users/walshca/.oh-my-zsh"

# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Uncomment the following line to automatically update without prompting.
DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

plugins=(git)

source $ZSH/oh-my-zsh.sh


source ~/code/bin/bash_aliases
PATH=~/bin:~/Library/Python/3.8/bin:$PATH

alias proj='cd ~/work/the-code-project'
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

export VISUAL="$(command -v vscode_w)"

setopt CORRECT
setopt CORRECTALL
setopt AUTO_CD

setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# Modified from ~/.oh-my-zsh/themes/robbyrussell.zsh-theme
PROMPT='%(?::%{$fg_bold[red]%}?%? %b)'
PROMPT+='%{$fg[cyan]%}%~ '
PROMPT+='$(git_prompt_info)'
PROMPT+='%{$fg[cyan]%}%#%{$reset_color%} '

ZSH_THEME_GIT_PROMPT_PREFIX=""
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg_bold[yellow]%}✘"
ZSH_THEME_GIT_PROMPT_CLEAN=""

precmd() {
  if [ "$(git_current_branch)" = master ] || [ "$(git_current_branch)" = develop ]; then
    ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}"
  else
    ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[red]%}"
  fi
}

# export NVM_DIR="$HOME/.nvm"
# [ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"
# [ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && . "/usr/local/opt/nvm/etc/bash_completion.d/nvm"

add-zsh-hook -Uz chpwd(){ source <(tea -Eds) }  #tea
function command_not_found_handler {
  tea -X $*
}
```

## powershell with custom prompt
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
## Autocorrect
Currently using git config `help.autocorrect=10` which helps with typos in sub-commands
- [ ] Consider installing [`thefuck`](https://github.com/nvbn/thefuck) and see if it doesn't break the shell prompt?
- [ ] NEXT, consider https://lib.rs/crates/fixit-cli (supports [[pwsh]])
## CURRENT: pwsh with oh-my-posh
Finally I switched to [oh-my-posh](https://ohmyposh.dev/) -- I like that it is more cross-shell now, not tied to [[pwsh]].
See config [here](../.go-my-posh.yaml). 

- [ ] PWD segment can it truncate to the git repo? https://starship.rs/config/#directory `truncate_to_repo`
	- [ ] To use another segment's template properties in a template, you can make use of `{{ .Segments.Segment }}` in your template where .Segment is the name of the segment you want to use with the first letter uppercased: https://ohmyposh.dev/docs/configuration/templates#template-logic
- [ ] Duration like https://starship.rs/config/#command-duration: The cmd_duration module shows how long the last command took to execute. Would be nice to show desktop notifications/beep when LONG command completes.
- [ ] Anything else interesting in https://starship.rs/config/ ?
- [ ] Release notes for new feature by email? like an github releases -> RSS tool?
- [ ] https://ohmyposh.dev/docs/segments/health/strava ⏫ 
- [ ] https://ohmyposh.dev/docs/segments/health/withings

### debugging prompt being slow
See https://ohmyposh.dev/docs/faq#the-prompt-is-slow-delay-in-showing-the-prompt-between-commands
Run `oh-my-posh debug | head -n 20` to see a nice performance summary

```
$ oh-my-posh debug | head -n 20

Version: 24.19.0

Shell: pwsh (7.5.0)

Prompt:

 ~/my_repo_dir my_branch_name ≡

Segments:

ConsoleTitle(false) -   0 ms
Status(false)      -   0 ms
Python(false)      -   1 ms
Path(true)         -   0 ms
Git(true)          - 223 ms
Root(false)        -   0 ms

Run duration: 237.471959ms
```

One possibility os setting each repo in `.gitmodules` to `ignore = dirty` https://stackoverflow.com/a/12111569/771768

By configuring git: `ignore_submodules: { "*": "dirty" }` that brought down the time *a lot*
```
Git(true)          -  20 ms
```
- [ ] Try this on #windows 
### Fixed bug with templates
My [git segment](https://ohmyposh.dev/docs/segments/scm/git) wasn't rendering right:
```yaml
  - type: git
    style: plain
    foreground: "#6871FF"
    properties:
      branch_icon: ""
      fetch_status: true
    templates:
    - " {{.HEAD}} "
    - "{{if .BranchStatus}}{{.BranchStatus}}{{end}}"
```
All variables i.e. `.HEAD` were empty, and it defaulted to the default text.

Workaround to use `template` which rendered variables correctly...
```yaml
    template: " {{.HEAD}} {{if .BranchStatus}}{{.BranchStatus}}{{end}}"
```
Real fix was to upgrade to [v24.1.0](https://github.com/JanDeDobbeleer/oh-my-posh/releases/tag/v24.1.0).

### Won't work for me to use AWS segment
- Want to use: https://ohmyposh.dev/docs/segments/cloud/aws
- But https://github.com/JanDeDobbeleer/oh-my-posh/blob/main/src/segments/aws.go only reads from `~/.aws/config` 
	- but the "get AWS token from hashicorp vault script" we use only writes to `~/.aws/credentials`

If we added some extra metadata to that script, I'd want to customize:
- only turn on for certain git repo paths
- map account numbers -> nice account name?