# PLAN: Push-Location Stack Display in Oh My Posh

## Problem

When using `Push-Location`/`Pop-Location` to navigate directories, the stack is invisible — no standard prompt segment shows it. You can get lost: how many `Pop-Location` calls do you need? Where will you land?

**Goal:** show the pushd stack (or at minimum the depth) in the oh-my-posh prompt, with no display when the stack is empty.

## Scope

Two decisions to make before implementing:

1. **What to show:** count-only (`2x ~/proj`) vs top-of-stack path (`↩ ~/proj`) vs full stack (`~/proj ← ~/tmp`)
2. **How to implement:** built-in `.StackCount` (OMP Path segment) vs env vars via `Set-PoshContext` hook

## Background

### Getting the stack in PowerShell

[`Get-Location -Stack`](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-location?view=powershell-7.5) exposes the current location stack. Most-recently pushed path is first:

```powershell
# All paths
Get-Location -Stack | Select-Object -ExpandProperty Path

# Top of stack only
(Get-Location -Stack | Select-Object -First 1).Path
```

### Option A: `.StackCount` in the built-in Path segment

[OMP's Path segment](https://ohmyposh.dev/docs/segments/system/path) exposes `.StackCount` — shows only the count, not paths:

```json
{
  "type": "path",
  "template": "{{ if gt .StackCount 0 }}{{ .StackCount }}x {{ end }}{{ .Path }}"
}
```

- (+) Zero config, no profile changes
- (-) Count only — no idea which directory is on top

### Option B: `Set-PoshContext` hook + env vars + text segment

Since [OMP v28](https://github.com/JanDeDobbeleer/oh-my-posh/releases/tag/v28.0.0) removed the old `command` segment, the recommended pattern is to compute values in `Set-PoshContext` (PowerShell's prompt hook) and read them via `.Env.VAR` in a `text` segment.

> **Note:** In pwsh the hook is `Set-PoshContext` (an alias). The lowercase `set_poshcontext()` is the zsh/bash/fish variant. The docs show both; use the alias form for pwsh.

Add to `$PROFILE`:

```powershell
function Set-EnvVar([bool]$originalStatus) {
    $stack = @(Get-Location -Stack | Select-Object -ExpandProperty Path)
    $env:POSH_PUSHD_TOP   = if ($stack.Count) { $stack[0] } else { "" }
    $env:POSH_PUSHD_STACK = if ($stack.Count) { $stack -join " <- " } else { "" }
    $env:POSH_PUSHD_COUNT = $stack.Count
}
New-Alias -Name 'Set-PoshContext' -Value 'Set-EnvVar' -Scope Global -Force
```

Add a `text` segment to the OMP config:

```json
{
  "type": "text",
  "template": "{{ if .Env.POSH_PUSHD_TOP }}↩ {{ .Env.POSH_PUSHD_TOP }}{{ end }}"
}
```

Or show the full stack:

```json
{
  "type": "text",
  "template": "{{ if .Env.POSH_PUSHD_STACK }}⇄ {{ .Env.POSH_PUSHD_STACK }}{{ end }}"
}
```

- (+) Shows actual paths, not just count
- (+) Composable — can format/truncate arbitrarily in PowerShell
- (-) One extra function in `$PROFILE`; env vars persist in child processes (cosmetic issue)

## POC Steps

- [ ] Try Option A first (`.StackCount` in existing Path segment template) — zero friction, check if count-only is good enough
- [ ] If count isn't enough: add `Set-PoshContext` + `POSH_PUSHD_TOP` env var + `text` segment
- [ ] Verify the env var approach works with the existing `Set-PoshContext` alias if one already exists in `$PROFILE`
- [ ] Test with: 0 pushes (nothing shows), 1 push (top shown), 3 pushes (only top shown or full stack)
- [ ] Decide on truncation: show full path, or `~/...` abbreviated? Add home-path substitution if needed:
  ```powershell
  $env:POSH_PUSHD_TOP = $stack[0] -replace [regex]::Escape($HOME), "~"
  ```

## Testing: Pester + `oh-my-posh print primary --plain`

`oh-my-posh print primary` renders the prompt from a config file without a live terminal. `--plain` strips ANSI codes for exact string comparison. Combined with Pester, this gives snapshot tests for the rendered prompt.

Key flags for deterministic output:

| Flag | Purpose |
|---|---|
| `--config <path>` | Which OMP theme to render |
| `--plain` | Strip ANSI, makes string comparison work |
| `--terminal-width 120` | Fixed width so line-breaking is deterministic |
| `--pwd` / `--pswd` | Override current directory shown in prompt |
| `--stack-count <n>` | Override stack count (for `.StackCount`-based approach) |

> **Note:** `--stack-count` only feeds the `.StackCount` variable in the Path segment. To test the env-var approach (Option B), set `$env:POSH_PUSHD_TOP` before calling `oh-my-posh print`.

### Testing the `Set-PoshContext` logic independently

The hook is plain PowerShell — test it in isolation before wiring to OMP:

```powershell
Describe "Set-PoshContext populates env vars" {
    BeforeEach {
        $env:POSH_PUSHD_TOP   = ""
        $env:POSH_PUSHD_COUNT = 0
    }

    It "clears env vars when stack is empty" {
        # Start fresh, don't push anything
        Set-EnvVar $true
        $env:POSH_PUSHD_TOP | Should -BeExactly ""
        [int]$env:POSH_PUSHD_COUNT | Should -Be 0
    }

    It "shows top of stack after Push-Location" {
        $tmp = New-Item -ItemType Directory -Path (Join-Path $env:TEMP ("posh-test-" + [guid]::NewGuid()))
        Push-Location $tmp.FullName
        Set-EnvVar $true
        $env:POSH_PUSHD_TOP | Should -BeExactly $tmp.FullName
        Pop-Location
        Remove-Item -Recurse -Force $tmp
    }
}
```

### Snapshot testing rendered prompt output

Spawn a fresh `pwsh` process so the location stack is isolated (the stack is per-runspace):

```powershell
Describe "OMP prompt rendering" {
    BeforeAll {
        $script:Config = Join-Path $PSScriptRoot "../.go-my-posh.yaml"
    }

    It "shows no pushd indicator when stack is empty" {
        $out = & oh-my-posh print primary `
            --config $script:Config `
            --shell pwsh `
            --plain `
            --terminal-width 120 `
            --pwd (Get-Location).Path `
            --pswd (Get-Location).Path `
            --stack-count 0

        $out | Should -Not -Match "↩"
        $out | Should -Not -Match "  +"   # no double spaces from missing segment
    }

    It "renders pushd indicator via env var (full chain)" {
        $script = @"
`$env:POSH_PUSHD_TOP = "$HOME"
oh-my-posh print primary --config '$script:Config' --plain --terminal-width 120
"@
        $out = pwsh -NoProfile -NonInteractive -Command $script
        $out | Should -Match ([regex]::Escape("↩"))
    }
}
```

**Snapshot approach (recommended for spacing/alignment regressions):** once output looks right, store it:

```powershell
$expected = Get-Content "$PSScriptRoot/snapshots/prompt-no-stack.txt" -Raw
$out | Should -BeExactly $expected
```

Update snapshots intentionally when you change the template; `git diff snapshots/` is the review UI. See [[testing-golden]] for the general pattern.

### What can't be integration-tested here

- Terminal reflow/resize behavior (terminal-specific, not OMP's output)
- iTerm2/Windows Terminal rendering of specific Unicode glyphs

## Risks

**`Set-PoshContext` alias conflict:** if `$PROFILE` already has a `Set-PoshContext` alias or function, `New-Alias -Force` will overwrite it silently. Check first; consider merging into one function.

**Env var persistence:** `$env:POSH_PUSHD_TOP` is visible to child processes. Unlikely to cause issues but worth knowing.

**Stack is per named stack:** `Push-Location` supports named stacks via `-StackName`. `Get-Location -Stack` returns the *default* stack only. If using named stacks, the hook needs `Get-Location -StackName <name>` for each stack.

**Prompt perf:** `Get-Location -Stack` is fast (in-memory), but if the prompt is already slow (check with `oh-my-posh debug`), any hook adds up. See [[shell.prompt#debugging prompt being slow]].

## Unresolved Questions

- [ ] Is count-only (Option A) good enough, or is seeing the actual path important enough to add the hook?
- [ ] What truncation/formatting for long paths? Home substitution (`~`)? Max chars?
- [ ] If using Option B: should the full stack be shown, or just top-of-stack?
- [ ] Does `POSH_PUSHD_COUNT` need to be an int in the env var, or is string fine for the template?

## Related

- [[shell.prompt#app-idea pushd stack display in prompt]] — origin of this plan
- [[testing-golden]] — golden/snapshot testing patterns; Pester snapshots follow the same principles
- [[pwsh.raii.PLAN]] — `Push-Location`/`Pop-Location` as RAII; related to stack management
- [OMP Path segment `.StackCount`](https://ohmyposh.dev/docs/segments/system/path)
- [OMP Templates `.Env`](https://ohmyposh.dev/docs/configuration/templates)
- [OMP v28 release — removed `command` segment](https://github.com/JanDeDobbeleer/oh-my-posh/releases/tag/v28.0.0)
