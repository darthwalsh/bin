## Shell integration with pwsh
https://devblogs.microsoft.com/commandline/shell-integration-in-the-windows-terminal/
- [ ] Try this
```powershell
function Global:__Terminal-Get-LastExitCode {
  if ($? -eq $True) {
    return 0
  }
  if ("$LastExitCode" -ne "") { return $LastExitCode }
  return -1
}
```


