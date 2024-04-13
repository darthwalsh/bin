I want to understand different [new experimental feature](https://learn.microsoft.com/en-us/powershell/scripting/learn/experimental-features)s of [[pwsh]] that might impact my workflow.

- [x] Current as of pwsh 7.4
- [ ] Re-evaluate with new pwsh 🛫2024-11-20 

## Removed

### [PSNativePSPathResolution](https://learn.microsoft.com/en-us/powershell/scripting/learn/experimental-features?view=powershell-7.4#psnativepspathresolution)
*REMOVED in 7.3*
- [x] Try `code ~/a.txt` on #windows
  - Answer: creates `%cd%\~\a.txt` file 🙁
  - You'd hope that tab complete would Resolve-Path to get a path that `code.cmd` can use? Does NOT, even on default profile
  - BUT! doesn't work to TAB Complete for files that don't exist yet
- [-] Try `code ~/a.txt` on #macbook

- [ ] Wait for pwsh 7.5 [release](https://github.com/PowerShell/PowerShell/releases) which introduces `PSNativeWindowsTildeExpansion` which fixes this behavior on Windows 🛫2024-11-20 
- [ ] THEN, maybe, look into why PSNativePSPathResolution was discontinued?

## Mainstream

### [PSNativeCommandArgumentPassing](https://learn.microsoft.com/en-us/powershell/scripting/learn/experimental-features?view=powershell-7.4#psnativecommandargumentpassing)
Now is enabled by default:
https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_parsing?view=powershell-7.4#passing-arguments-that-contain-quote-characters
- [ ] Test some annoying ssh command that needed escaped quotes from ansible? Or `echo` vs `/bin/echo`? #macbook
Might be interesting to post about on Socials

### [PSNativeCommandErrorActionPreference](https://learn.microsoft.com/en-us/powershell/scripting/learn/experimental-features?view=powershell-7.4#psnativecommanderroractionpreference)
- [ ] Try `$PSNativeCommandUseErrorActionPreference = $true` to replace `if ($LASTEXITCODE -ne 0) { throw ... }` in scripts?
- [ ] Repport issue? set to `$False` by default on my system....? 

## Pending
### [PSCommandWithArgs](https://learn.microsoft.com/en-us/powershell/scripting/learn/experimental-features?view=powershell-7.4#pscommandwithargs)
>parameter populates the $args built-in variable that can be used by the command.
```bash
pwsh -CommandWithArgs '$args | % { "arg: $_" }' arg1 arg2
```
- [ ] Try this on #macbook

### [PSModuleAutoLoadSkipOfflineFiles](https://learn.microsoft.com/en-us/powershell/scripting/learn/experimental-features?view=powershell-7.4#psmoduleautoloadskipofflinefiles)
- [ ] Add a MAYBE in windows `pwsh` setup when it comes to "Downloading OneDrive?" being annoying 🛫 2024-11-20 




