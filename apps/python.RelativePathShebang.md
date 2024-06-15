I've written several python scripts that need installed packages, so I often write a [`.ps1` wrapper](../stravaCook.ps1) that calls into some virtual environment:

```powershell
<# Expected requirements in ~/pye_nv
stravacookies==1.3
firebase-admin==6.3.0
#>
. '~/pye_nv/bin/python' (Join-Path $PSScriptRoot strava_cook.py)
```

Could it be possible to have a standalone python file with shebang that just invokes the right python file?

Bonus points if it can automatically install pip requirements as needed.

https://stackoverflow.com/a/33225909/771768 lists different solutions, none of which will work in Windows (also, because shebang)

- [ ] Does Windows support anything like shebang? Otherwise this doesn't help me that much  #windows 

- [ ] Try upgrading env (on BSD macOS seems not possible)
- [ ] Try using awk/perl shebang with smalls script to pick relative python
- [ ] Try exec trick

## Another idea
Instead, using a python wrapper script could work:
https://www.franzoni.eu/single-file-editable-python-scripts-with-dependencies/

1. Create a temp_path for venv
	1. hashing requirements
	2. hashing script path
	3. better to use temp dir, but then do you need to think about cleanup?
2. `sys.path.insert(0, temp_path/**/site-packages)`
3. `import requests`
4. `except ModuleNotFoundError as e:` *(BTW, could catch `ImportError` but we can be more spectic)*
5. Run `pip install --prefix temp_path e.name`
	1. `subprocess.check_call([sys.executable, '-m', 'pip', 'install', ...`
	2. OR `from pip import main as pipmain; pipmain(["install", ...`
	3. MAYBE include the full version


- [ ] Does this approach give IDE support?
	- [ ] vscode can use venv with python path
	- [ ] --prefix solution doesn't give that
		- [ ] can set setting `"python.analysis.extraPaths": [ "./venv_/lib/python3.11/site-packages"  ]`

- [x] (Bonus points if I can have python script without extension... unless \*NIX supports something like `PATHEXT`?) #macbook
	- not supported in pwsh itself: https://github.com/PowerShell/PowerShell/issues/7755#issuecomment-461230875
