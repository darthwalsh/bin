# bin
Scripts for windows / mac / linux, and also documentation for me.

Feel free to send a PR!

## Install
Clone the repo to e.g. `~/bin`:
```
git clone https://github.com/darthwalsh/bin.git
# OR
git clone git@github.com:darthwalsh/bin.git
```

### One-line Linux install for SSH or docker

```powershell
ssh $NAME 'git clone --depth 1 https://github.com/darthwalsh/bin.git ~/.dw-bin 2>/dev/null || git -C ~/.dw-bin pull && export PATH="$HOME/.dw-bin:$HOME/.dw-bin/lnx:$PATH" && source ~/.dw-bin/bash_aliases && exec bash -i'

# Start a new docker container from image with a volume mount
docker run --rm -it -v ~/code/bin:/usr/local/bin/.dw-bin $IMAGE bash -i -c 'export PATH="/usr/local/bin/.dw-bin:$PATH" && source /usr/local/bin/.dw-bin/bash_aliases && exec bash -i'

# Existing docker with git
docker exec -it -u 0 $NAME bash -lc 'git clone --depth 1 https://github.com/darthwalsh/bin.git /usr/local/bin/.dw-bin 2>/dev/null || git -C /usr/local/bin/.dw-bin pull && source /usr/local/bin/.dw-bin/bash_aliases && exec bash -i'

# Or without git, manually copy from host
docker cp ~/code/bin "${NAME}:/usr/local/bin/.dw-bin" && docker exec -it -u 0 "${NAME}" bash -ic 'export PATH="/usr/local/bin/.dw-bin:$PATH" && 
source /usr/local/bin/.dw-bin/bash_aliases && exec bash -i'
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

## Language-Specific setup

### `python`
Some scripts like [gpx.py](./gpx.py) use [`/// script; dependencies=` inline script metadata](https://packaging.python.org/en/latest/specifications/inline-script-metadata/) and should be run with [`pipx`](https://pipx.pypa.io/) or `uv`.

Then format and lint with 
```
pipx run ruff check --fix && pipx run ruff format
```
*When fixing, Ruff's lint hook must be placed before formatter*

## Testing

The scripts are not well tested, but see [tests/](./tests/README.md) when fixing bugs.
