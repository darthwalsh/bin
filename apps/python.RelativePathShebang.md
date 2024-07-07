## I used to write scripts that hardcoded a venv

I've written several python scripts that need installed packages, so I often write a [`.ps1` wrapper](../stravaCook.ps1) that calls into some hardcoded virtual environment that I manually created and installed packages into:
```powershell
<# Expected requirements in ~/pye_nv
stravacookies==1.3
firebase-admin==6.3.0
#>
. '~/pye_nv/bin/python' (Join-Path $PSScriptRoot strava_cook.py)
```

Problems:
- Each python script needs a wrapping script file that just invokes python
- venv path isn't mapped to these packages, i.e. what process owns `~/pye_nv/`?
- I've had problems with powershell's handling of python's stdin/stdout not being transparent
- IDE python language server needs to know where these packages are for autocomplete

## Solutions to needing wrapping script
### Solution? Relative shebang
Can avoid needing the wrapping script file if the python file is executable, and has a [[shebang]] that invokes the right python.

**If** the venv was already activated, it would be as [simple](https://realpython.com/python-shebang/#how-can-you-define-a-portable-shebang) as just using `#!/usr/bin/env python3` 

https://stackoverflow.com/a/33225909/771768 lists different solutions, none of which 
- Try upgrading env (on BSD macOS seems not possible)
- Try using awk/perl shebang with smalls script to pick relative python
- Try exec trick

Alas, none of these seem to work in Windows.
Also, the concept of a shebang is totally foreign on windows, which creates executable associations based on file suffix. The `.PY` launcher can understand "virtual shebangs": https://stackoverflow.com/questions/7574453/shebang-notation-python-scripts-on-windows-and-linux

This introduces a new problem, that from the \*NIX shell you need to include the `.py` suffix when executing a script. 
I wondered if there was a workaround, like how Windows supports `PATHEXT` to search i.e. `.exe`, `.bat`, etc
But that idea was [considered and rejected in pwsh itself]( https://github.com/PowerShell/PowerShell/issues/7755#issuecomment-461230875).
Instead, the simplest solution to this is probably add some PROFILE startup code to:
1. loop over `*.py` 
2.  `Set-Alias strava_cook (Resolve-Path strava_cook.py)` 
	1. could alias to some general `my_script_runner strava_cook.py` and not rely on shebangs at all. (!except that powershell aliases [don't support arguments](https://stackoverflow.com/a/4167071/771768)!)

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
#### Tools to look into
- [ ] [pipx](https://pipx.pypa.io/stable/)
	- [ ] inline script metadata in [example](https://pipx.pypa.io/stable/examples/#pipx-run-examples)
	- Shebang not necessary if using aliases, but something to know about
		- issue with space? `~/Library/Application Support/pipx` https://pipx.pypa.io/stable/troubleshooting/#macos-issues
		- But! on my machine it's at `/opt/homebrew/bin/pipx`
		- https://github.com/pypa/pipx/discussions/1162
- [ ] [pdm](https://pdm-project.org/en/latest/)
	- [ ]  inline script metadata in [example](https://pdm-project.org/en/latest/usage/scripts/#single-file-scripts)
- [ ] https://fades.readthedocs.io/en/latest/readme.html#how-to-mark-the-dependencies-to-be-installed
- [ ] https://github.com/jaraco/pip-run?tab=readme-ov-file#script-declared-dependencies
- [ ] other tools from https://pipx.pypa.io/stable/comparisons

## Solutions to IDE support
- [ ] Any tool or vscode extension to set i.e. `python.analysis.extraPaths` for the currently open script?
