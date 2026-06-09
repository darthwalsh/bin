[Chocolatey](https://chocolatey.org/) is a [[package manager]] for Windows.
## Install as user account
https://superuser.com/questions/1095475/chocolatey-as-non-admin-user
- [ ] Try this if I need to use choco on new machine
## Dumping list of installed packages
`choco list` is simple
- `--local-only` used to be required, but switch is removed and now is default
- *Could* use `--include-programs` to get all install programs, same as [[winget]]
Wrote script [`chocodump`](../win/chocodump.ps1) to output the packages [back into the git repo](../win/chocofile-DISCOVERY.txt).

- [ ] Try the [powershell module](https://www.powershellgallery.com/packages/chocolatey) which might give the Description for each?

## Where files land

The `.nupkg` unpacks under `C:\ProgramData\chocolatey\lib\<pkg>`, shims in `chocolatey\bin`. Most packages just run the underlying MSI/EXE installer, so real [[package.files]] land in `Program Files` + registry like a manual [[package.install]].
