`cd` is a shell-builtin; it doesn't make sense to spawn a new child process that changes its directory.

In [[pwsh]] it's an Alias: `cd -> Set-Location`

- [ ] Try zoxide which supports windows/mac, and supports powershell