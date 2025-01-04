[Chocolatey](https://chocolatey.org/) is a [[package manager]] for Windows.

## Dumping list of installed packages
`choco list` is simple
- `--local-only` used to be required, but switch is removed and now is default
- *Could* use `--include-programs` to get all install programs, same as [[winget]]
Wrote script [`chocodump`](../win/chocodump.ps1) to output the packages [back into the git repo](../win/chocofile-DISCOVERY.txt).

- [ ] Try the [powershell module](https://www.powershellgallery.com/packages/chocolatey) which might give the Description for each?
## Install as user account
https://superuser.com/questions/1095475/chocolatey-as-non-admin-user
- [ ] Try this on new PC