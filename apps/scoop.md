scoop is a [[package manager]] for Windows.
## Dumping list of installed packages
Couple [commands](https://github.com/ScoopInstaller/Scoop/wiki/Commands) could be used
- `scoop list` generates [[pwsh]] objects, can pipe to cmdlets like `Group-Object Name`
- `scoop export --config` generates same data in JSON

Wrote script [`scoopdump`](../win/scoopdump.ps1) to output the packages [back into the git repo](../win/scoopfile-DISCOVERY.txt).

- [ ] See if it's easy to include `.Description` -- doesn't seem to be easily exported today...?
## Problem with `scoop.cmd` for updating
TL;DR: `scoop.cmd update *`  will fail to update `pwsh` even it no previous instances exist.
See write-up in https://github.com/ScoopInstaller/Main/issues/5255

Workaround: 
>Instead, scoop.cmd could detect it is being run by powershell.exe and default to using powershell instead of pwsh

Closed because we have no idea how to accomplish:
>This is not possible to implement in pure Batch - it's a very primitive scripting language.

Getting direct parent process is simple with WMI, but might be too slow: https://stackoverflow.com/a/53473125/771768
