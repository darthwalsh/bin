`winget` is a [[package manager]] CLI for Windows, created by Microsoft.
## Dumping list of installed packages
[Commands](https://learn.microsoft.com/en-us/windows/package-manager/winget/#commands) that could be used:
- `winget export wg.json --source winget`
    - limit source to winget, otherwise for me it also includes a single MSStore

Wrote script [`wingetdump`](../win/wingetdump.ps1) to output the packages [back into the git repo](../win/wingetfile-DISCOVERY.txt).
## Winget Configuration is different
[Overview](https://learn.microsoft.com/en-us/windows/package-manager/configuration/) - declarative YAML file with system prereq/assertions kind of like [[Ansible]]
`winget configure` [command](https://learn.microsoft.com/en-us/windows/package-manager/winget/configure) installs from config file
`winget configure export` is not supported [Add support to export configuration for WinGet administrator settings](https://github.com/microsoft/winget-cli/issues/4211)
