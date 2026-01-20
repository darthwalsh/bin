---
aliases:
  - pkgx
---
> [!NOTE] `pkgx` CLI was called `tea` in 2023

- [ ] #android  try https://docs.pkgx.sh/pkgx/installing-pkgx for latest packages

## pkgx Ecosystem

- `pkgx`: The main "run anything" binary - https://github.com/pkgxdev/pkgx
- `dev`: Companion tool for per-project environments via shell hooks - https://github.com/pkgxdev/dev
- `pkgm`: Tool for installing pkgx packages to `/usr/local`
- `mash`: Script-packaging
- `pkgo`: Building "non-packagable" complex projects

### Installation
- https://github.com/pkgxdev/pkgx/wiki/Basics#installing-pkgx
- https://docs.pkgx.sh/

### Legacy tea.xyz links (historical)
- https://github.com/teaxyz/cli
- https://github.com/teaxyz/setup/blob/main/install.sh

## `pwsh` shell support status

As of 2025, [[pwsh]]  is **NOT currently supported** for shell-hook integration.

- The `dev` tool explicitly states: "We support macOS & Linux, **Bash & Zsh**. PRs are very welcome to support more shells."
- Windows native support is pending but doesn't support many packages yet

### Historical shell-hook implementation (tea.xyz)

[tea README](https://github.com/teaxyz/cli/blob/3e66ef99ea1fe9db92f8035a716544e4bd26c581/README.md#now-see-here-fella-i-hate-installers) 

> Our (optional) virtual environment manager functionality needs a shell hook in the relevant `.rc` file:
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

### mise has pwsh hooks too
https://github.com/jdx/mise/blob/5b2d79500ab89b2a4fe1a09a5abbcce1bde3cc55/src/shell/pwsh.rs#L99
```powershell
function global:prompt {{
	if (Test-Path -Path Function:\_mise_hook){{
		_mise_hook
	}}
	& $__mise_pwsh_previous_prompt_function
}}
```
### oh-my-posh has custom hooks for ZSH and PWSH
https://ohmyposh.dev/docs/installation/prompt
Look at how `zsh` is implemented, and copy logic for a `tea` integration with `pwsh`

`pwsh` implementation defines `function prompt` https://github.com/JanDeDobbeleer/oh-my-posh/blob/0f8929ed135c577a22c80f5d32d17214134ad2bf/src/shell/scripts/omp.ps1#L395


## Finding globally installed tea packages

Tea had this extremely magical feature where if you symlink a package to `tea`, it will auto-magically download and run the name of the symlink as a package, on-demand.

```powershell
gci /usr/local/bin/glow | Where-Object LinkTarget -match tea | ForEach-Object Name
glow
```

shows `glow -> tea` 
