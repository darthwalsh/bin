In POXIX shells like bash, it is easy to run a command with some env var set just for that command:
```
bash-3.2$ export ABC=DEF
bash-3.2$ bash -c 'echo $ABC'
DEF
bash-3.2$ ABC=XYZ bash -c 'echo $ABC'
XYZ
bash-3.2$ echo $ABC
DEF
```


This isn't supported in [[pwsh]] though. How to run one command with ENV VAR set?
- [ ] Try writing a custom handler like the [starts with space don't save to history](https://github.com/darthwalsh/bin/blob/c106c20759afaa316f72322a795bfc0fccf7975b/Microsoft.PowerShell_profile.ps1#L9)

## Workaround, use a subshell
Creating a [subprocess](https://stackoverflow.com/a/10856211/771768) is more common in bash, but a workaround solution in powershell

```powershell
$env:ABC = 'DEF'
pwsh -Command {
  $env:ABC = 'XYZ'
  echo $env:ABC
}
echo $env:ABC
```

One problem, `bash` takes only 1ms to start a subshell (or 60ms to start from powershell), but running a pwsh command takes 1050ms on my macbook to load my profile.

Workaround: use `-NoProfile` argument `pwsh -nop -c {` which brings it down to 195ms

## Workaround, use `env`
```powershell
$env:ABC = 'DEF'
env ABC='XYZ' pwsh -c { echo $env:ABC }
```
- [ ] Problem, is `/usr/bin/env` easy to install on #windows
