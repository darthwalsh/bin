- [ ] import ToC for `pwsh.*.md`?

## Faster Profile loading in interactive mode
https://stackoverflow.com/a/34098997/771768
- [ ] try `[Environment]::UserInteractive` but also need to scan CLI args?
Not so important when using interactive PWSH, but it's slow to use any powershell from BAT or BASH on windows.

## Get last pwsh value
Shift+Enter handler to tee-object to `$PSLastVariable`
- [ ] https://stackoverflow.com/a/49303366/771768

## rerun last command as sudo
on bash it's trivial because `!!` expands to the previous input: `sudo !!`

https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_automatic_variables?view=powershell-7.4#section
use `$$` instead but not exactly the same? on bash `echo ab; echo cd` then `!!` expands to both commands.

No auto variable for the entire line?!?
- [ ] Check on ChatGPT / StackOverflow

## Get result of last command
Would be nice to have an auto-variable, i.e. `$!`:
```powershell
$ 40 + 2
42
$ $!
42
```
- [ ] https://stackoverflow.com/questions/14351018/powershell-is-there-an-automatic-variable-for-the-last-execution-result/52485269#52485269
## Prevent closing main terminal window
- [ ] Doable in bash, but not sure about pwsh

https://superuser.com/a/465893/282374
>You can set `IGNOREEOF` to force the user to type `exit` or `logout` instead of just pressing ^D.

- [ ] NEXT, try alias `exit`: https://apple.stackexchange.com/a/219997/325877
## Change how gci shows file size
- [ ] https://superuser.com/a/468907/282374
```powershell
Update-TypeData -TypeName System.IO.FileInfo -MemberName FileSize  -MemberType ScriptProperty -Value { ...
```