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

https://stackoverflow.com/a/33225909/771768
- [ ] Try upgrading env (on BSD macOS seems not possible)
- [ ] Try using awk/perl shebang with smalls script to pick relative python
- [ ] Try exec trick


(Bonus points if I can have python script without extension... unless \*NIX supports something like `PATHEXT`?)
