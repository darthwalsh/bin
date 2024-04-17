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
https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_parsing?view=powershell-7.4#passing-arguments-that-contain-quote-characters

Before this, I have done lot of annoying debugging using `/bin/echo` to see how quotes were being passed to native commands on macOS:

As a contrived example: on old `pwsh` I wanted to run the command `bash -c "gcc --version 2>&1 | head -n 1"` on some remote machines:
`ansible the_server -a 'bash -c "gcc --version 2>&1 | head -n 1"'`

The `-a` param should be parsed as `bash -c gcc --version 2>&1 | head -n 1`
But with the `Legacy` behavior it was passing `--version` as an arg to `ansible` which gave the wrong behavior!

Now `pwsh` passes the quoted args to native apps as expected 🎉

### [PSNativeCommandErrorActionPreference](https://learn.microsoft.com/en-us/powershell/scripting/learn/experimental-features?view=powershell-7.4#psnativecommanderroractionpreference)
- [x] Report issue? set to `$False` by default on my system....?
	- [x] https://github.com/MicrosoftDocs/PowerShell-Docs/pull/11026 🎉
- [x] Try `$PSNativeCommandUseErrorActionPreference = $true` to replace `if ($LASTEXITCODE -ne 0) { throw ... }` in scripts?
	- [x] Updated answer: https://stackoverflow.com/a/9949105/771768 🎉
- [x] Check #macbook  for `$LASTEXITCODE` in scripts 🛫 2024-04-15

## Pending
### [PSCommandWithArgs](https://learn.microsoft.com/en-us/powershell/scripting/learn/experimental-features?view=powershell-7.4#pscommandwithargs)
>parameter populates the $args built-in variable that can be used by the command.
```bash
pwsh -CommandWithArgs '$args | % { "arg: $_" }' arg1 arg2
```
- [x] Try this on #macbook : used `@PSBoundParameters` in some script, but not useful

### [PSModuleAutoLoadSkipOfflineFiles](https://learn.microsoft.com/en-us/powershell/scripting/learn/experimental-features?view=powershell-7.4#psmoduleautoloadskipofflinefiles)
- [ ] Add a MAYBE in windows `pwsh` setup when it comes to "Downloading OneDrive?" being annoying 🛫 2024-11-20 

### [PSFeedbackProvider](https://learn.microsoft.com/en-us/powershell/scripting/learn/experimental-features?view=powershell-7.4#psfeedbackprovider)
>PowerShell uses a new feedback provider to give you feedback when a command can't be found. The feedback provider is extensible, and can be implemented by third-party modules.

### [PSCommandNotFoundSuggestion](https://learn.microsoft.com/en-us/powershell/scripting/learn/experimental-features?view=powershell-7.4#pscommandnotfoundsuggestion)
>Recommends potential commands based on fuzzy matching search after a **CommandNotFoundException**.
---
`PSNativeCommandErrorActionPreference` is [enabled by default](https://learn.microsoft.com/en-us/powershell/scripting/learn/experimental-features?view=powershell-7.4#psnativecommanderroractionpreference), so `$ErrorActionPreference = "Stop"` will stop execution even for native programs

