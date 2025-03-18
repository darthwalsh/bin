# bin
Scripts for windows / mac / linux, and also documentation for me.

Feel free to send a PR!

## Install
Clone the repo:
```
git clone https://github.com/darthwalsh/bin.git
# OR
git clone git@github.com:darthwalsh/bin.git
```

## `bash` / `zsh`
Add this to `~/.bashrc` or `~/.zshrc`
```
source ~/bin/bash_aliases
PATH=~/bin:$PATH
```

Then, for OS specific-scripts add ones of these lines:

```
PATH=~/bin/lnx:$PATH
PATH=~/bin/mac:$PATH
```

## `powershell`

Edit the file `$PROFILE` to start with one of these lines:

```powershell
. ~/bin/lnx/Microsoft.PowerShell_profile.ps1
. ~/bin/mac/Microsoft.PowerShell_profile.ps1
. ~/bin/win/Microsoft.PowerShell_profile.ps1
```

Optionally, install:
- https://ohmyposh.dev/docs/installation/windows
```powershell
Install-Module posh-git -Scope CurrentUser
```

## `cmd`

There are some old commands from `cmd` are in Dropbox... but that's not supported here.  

# Language-Specific setup

## `python`
Some scripts like [gpx.py](./gpx.py) use [`/// script; dependencies=` inline script metadata](https://packaging.python.org/en/latest/specifications/inline-script-metadata/) and should be run with [`pipx`](https://pipx.pypa.io/).

Then format and lint with 
```
pipx run ruff check --fix && pipx run ruff format
```
*When fixing, Ruff's lint hook must be placed before formatter*
