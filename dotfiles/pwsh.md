---
description: PowerShell Guidelines applies to all powershell files
globs: ["**/*.ps1", "**/*.psm1"]
---

If I have `[CmdletBinding(SupportsShouldProcess)]`, nested cmdlets that support `ShouldProcess` will inherit the `-WhatIf`; so don't need `if ($PSCmdlet.ShouldProcess(...))` block.

Assume that bin/ is on the $PATH. Instead of `& "$PSScriptRoot/the-script.ps1" arg1` just use `the-script arg1`
To find an unknown command `foo`, run `pwsh -c 'wh foo'`. Look for the first non-alias CommandType, and then look at Source.

Don't need `if ($LASTEXITCODE -ne 0)`: `PSNativeCommandErrorActionPreference` is Enabled by default, so `$ErrorActionPreference = "Stop"` will stop execution even for native programs. If a command exits with another exit code, it will throw.

