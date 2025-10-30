---
aliases:
  - PythonScriptsWithDependencies
---
*Outcome: currently using [uv](https://docs.astral.sh/uv/guides/scripts/#declaring-script-dependencies)*
- [ ] rename to something like `PythonScriptsWithDependencies`
- [ ] revisit with https://whitescreen.nicolaas.net/programming/windows-shebangs
- [ ] revisit with https://thisdavej.com/share-python-scripts-like-a-pro-uv-and-pep-723-for-easy-deployment/#making-it-even-easier-to-run-with-a-python-shebang
## Problem: I used to write scripts that hardcoded a venv

I've written several python scripts that need installed packages, so I often write a [`.ps1` wrapper](../stravaCook.ps1) that calls into some hardcoded virtual environment that I manually created and installed packages into:
```powershell
<# Expected requirements in ~/pye_nv
stravacookies==1.3
firebase-admin==6.3.0
#>
. '~/pye_nv/bin/python' (Join-Path $PSScriptRoot strava_cook.py)
```
Solves:
- One PY file and PS1 script in git can work on both Windows and macOS
- Doesn't reinstall dependencies each execution
- Doesn't install dependencies globally
Problems:
- Each python script needs a wrapping script file that just invokes python
- No automation installs or upgrades packages using these version strings
- venv path isn't mapped to these packages, i.e. what process owns `~/pye_nv/`?
- `va.ps1` script enumerates parent directories for `*env*` folders, so need to mangle the folder name
- I've had problems with [[pwsh.encoding|powershell's handling of python's stdin/stdout]] not being transparent
	- (could be fixed if I used bash/zsh as scripting language!)
- IDE python language server needs to know where these packages are for autocomplete
- My scripts will get out of date with using frozen dependencies unless I manually upgrade on all machines
	- Another idea [[Upgrading.Dependencies]]
## Solutions to needing wrapping script
https://stackoverflow.com/q/23678993/771768 has a couple simpler solutions:
- Shebang to absolute path of venv python
- `sys.path.append` a relative path
- `activate_this_file = "/path/to/virtualenv/bin/activate_this.py"; exec(open(activate_this_file).read(), dict(__file__=activate_this_file))`)

### Solution? Relative shebang
Can avoid needing the wrapping script file if the python file is executable, and has a [[shebang]] that invokes the right python.

**If** the venv was already activated, it would be as [simple](https://realpython.com/python-shebang/#how-can-you-define-a-portable-shebang) as just using `#!/usr/bin/env python3` 

https://stackoverflow.com/a/33225909/771768 lists different solutions, none of which 
- Try upgrading env (on BSD macOS seems not possible)
- Try using awk/perl shebang with smalls script to pick relative python
- Try exec trick

**Alas, none of these seem to work in Windows.**
Also, the concept of a shebang is totally foreign on windows, which creates executable associations based on file suffix. The `.PY` launcher can understand "virtual shebangs": https://stackoverflow.com/questions/7574453/shebang-notation-python-scripts-on-windows-and-linux
- [ ] Test for `py.exe` ... Do I have the [python launcher](https://docs.python.org/3/using/windows.html#python-launcher-for-windows) for #windows ? Could I use it with a shebang like ~/virtual_en/script1/, ...2, etc?
- [ ] Test #windows  for default file assoc: https://stackoverflow.com/a/7574545/771768 


This introduces a new problem, that from the \*NIX shell you need to include the `.py` suffix when executing a script. 
I wondered if there was a workaround, like how Windows supports `PATHEXT` to search i.e. `.exe`, `.bat`, etc
But that idea was [considered and rejected in pwsh itself]( https://github.com/PowerShell/PowerShell/issues/7755#issuecomment-461230875).
Instead, the simplest solution to this is probably add some PROFILE startup code to:
1. loop over `*.py` 
2. create an alias `strava_cook` to `realpath strava_cook.py` 

But probably best to just alias to some general `my_script_runner strava_cook.py` and not rely on shebangs at all. 

### Solution? Inline snippet to set up venv and install packages
Instead, using a python snippet could work, like in:
- https://www.franzoni.eu/single-file-editable-python-scripts-with-dependencies/
- https://pip.wtf/
- https://github.com/dbohdan/pip-wtenv

In pseudocode, can simplify this a bit to avoid writing packages twice:
1. Create a temp_path for venv
	- hashing either the requirements OR the script path
	- base path of either the current-dir or system-temp or user-dir (then do you need to think about cleanup?)
2. `sys.path.insert(0, temp_path/**/site-packages)`
3. `try: import requests`
4. `except ModuleNotFoundError as e:` *(BTW, could catch `ImportError` but we can be more specific)*
	1. *could skip this and only install on first launch, but then if you change packages you need to manually `rm -rf`* 
5. Run `pip install --prefix temp_path {e.name}`
	1. shell out: `subprocess.check_call([sys.executable, '-m', 'pip', 'install', ...`
	2. pipmain lib: `from pip import main as pipmain; pipmain(["install", ...`
	3. downside: doesn't include the full version

Another limitation: need to also update `$PATH` and `$PYTHONPATH` if you launch subprocesses, but in-process i've never seen a problem.

Still need to solve the IDE python language server support.
- vscode can detect/use venv with an actual python path
- `pip install --prefix` doesn't create venv, so instead set `"python.analysis.extraPaths": [ "./venv_/lib/python3.11/site-packages" ]`

### Solution? Generalized script runner
I don't want to add some ugly script inline in each python script. There's probably a way to include it from some centralized script library, but it might be more clean to have an external runner.

Instead of creating my own custom REQUIREMENTS format, there's a standard for this: [PEP 723 – Inline script metadata](https://peps.python.org/pep-0723/) and see [new docs](https://packaging.python.org/en/latest/specifications/inline-script-metadata/#inline-script-metadata).
Instead of writing my own, I came across http://chriswarrick.com/blog/2023/01/15/how-to-improve-python-packaging and found several well-supported tools.
## Pipx seems to be most stable tool supporting script dependencies
[pipx](https://pipx.pypa.io/stable/) -- installed through [[brew]] or [[scoop]]

[Example of how to use inline script metadata](https://pipx.pypa.io/stable/examples/#pipx-run-examples)
You invoke `pipx run test.py pipx` which does the complicated part of creating a venv somewhere else, pip installing requests, and running the script. Create `test.py`:
> 
> ```python
> # /// script
> # dependencies = ["requests"]
> # ///
> 
> import sys
> import requests
> project = sys.argv[1]
> pipx_data = requests.get(f"https://pypi.org/pypi/{project}/json").json()
> print(pipx_data["info"]["version"])
> ```

- [ ] *does this code-block-inside-block-quote render right on GFM?? other tools? seems to be a bug in obsidian markdown processor* 🛫 2024-09-08 
- [ ] create global pre-commit rule that avoids used pinned version in scripts? https://chatgpt.com/s/t_68c6070560d08191b624715772a4e7d0
- [ ] later, upgrade `stravaCook.ps1` to use `/// script` and delete ps1, then update links to github blob
### Creating nice aliases
I want to be able to run `stravacook` from the CLI like the wrapper enables, instead of typing `pipx run ~/code/bin/strava_cook.py` like a caveman.

Creating the alias is easy by hardcoding a function in [shell profile](../Microsoft.PowerShell_profile.ps1)
```powershell
function stravacook { pipx run (Join-Path $PSScriptRoot strava_cook.py) @args }
```
(Why a powershell `function`? See [[shell.alias#pwsh]].)

- [ ] Considering adding a loop to find scripts with `/// script` and creating all aliases
### pipx in shebang might cause troubles
- Shebang not necessary if using aliases, but something to be aware of:
	- Some issue with space? `~/Library/Application Support/pipx` https://pipx.pypa.io/stable/troubleshooting/#macos-issues
	- But! on my machine it's at `/opt/homebrew/bin/pipx`
	- https://github.com/pypa/pipx/discussions/1162

## Other Tools to look into
- [ ] [pdm](https://pdm-project.org/en/latest/)
	- [ ]  inline script metadata in [example](https://pdm-project.org/en/latest/usage/scripts/#single-file-scripts)
- [ ] [uv](https://docs.astral.sh/uv/)
- [ ] https://fades.readthedocs.io/en/latest/readme.html#how-to-mark-the-dependencies-to-be-installed
- [ ] https://github.com/jaraco/pip-run?tab=readme-ov-file#script-declared-dependencies
- [ ] other tools from https://pipx.pypa.io/stable/comparisons

## Solutions to IDE support
Known issue: https://github.com/microsoft/vscode-python/issues/24916
IDE python language server needs to know where these packages are for autocomplete.
In [[vscode]] it can find any venv in your workspace, but pipx by default manages venvs somewhere else
- [ ] is there some pipx config to put the venvs within the workspace?

My manual workaround now is to 
1. Comment out the script body
2. Run `pipx run -v ./script.py`
3. Add the output path to [`.vscode/settings.json`](../.vscode/settings.json) `pthon.analysis.extraPaths`

- [ ] Any tool or vscode extension to automatically set i.e. `python.analysis.extraPaths` for the currently open script?
