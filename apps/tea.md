https://github.com/teaxyz/cli
https://github.com/teaxyz/cli/wiki/Basics#installing-tea
https://github.com/teaxyz/setup/blob/main/install.sh

## Finding globally installed packages

```powershell
gci /usr/local/bin/glow | Where-Object LinkTarget -match tea | ForEach-Object Name
glow
```

shows `glow -> tea` 

But on a new system, ideally I'll move more [[apps/brew/README]] packages over.

## `pwsh` magic support possible feature

[tea README](https://github.com/teaxyz/cli/blob/3e66ef99ea1fe9db92f8035a716544e4bd26c581/README.md#now-see-here-fella-i-hate-installers) 

> Our (optional) virtual environment manager functionality needs a shell hook in the relevant `.rc` file:
>        `add-zsh-hook -Uz chpwd(){ source <(tea -Eds) }`

`src/app.exec.ts` has [shell-specific logic ](https://github.com/teaxyz/cli/blob/1d0c1ff8f71bcb8b8c31bc80bac21c8a01add67a/src/app.exec.ts#L63)
```bash
  //TODO other shells pls #help-wanted

  case 'sh':
    env['PS1'] = "\\[\\033[38;5;86m\\]tea\\[\\033[0m\\] %~ "
    break
  case 'zsh':
    env['PS1'] = "%F{086}tea%F{reset} %~ "
    cmd.push('--no-rcs', '--no-globalrcs')
    break
  case 'elvish':
    cmd.push(
      '-norc'
    )
    break
  case 'fish':
```

[src/hooks/useShellEnv.ts](https://github.com/teaxyz/cli/blob/1d0c1ff8f71bcb8b8c31bc80bac21c8a01add67a/src/hooks/useShellEnv.ts) has ENV VARs that get some logic, like `PATH` and `TEA_PREFIX`


### Understanding `add-zsh-hook` and `chpwd`
https://github.com/rothgar/mastering-zsh/blob/master/docs/config/hooks.md explains hooks

Hooking `chpwd` in ZSH allows a custom shell function to run on every `cd` (presumably `pushd` etc)

https://github.com/zsh-users/zsh/blob/master/Functions/Misc/add-zsh-hook has an example

### oh-my-posh has custom hooks for ZSH and PWSH
https://ohmyposh.dev/docs/installation/prompt
Look at how `zsh` is implemented, and copy logic for a `tea` integration with `pwsh`


