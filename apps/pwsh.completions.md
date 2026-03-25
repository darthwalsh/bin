[MSDN docs](https://learn.microsoft.com/en-us/powershell/scripting/learn/shell/tab-completion?view=powershell-7.4)

- [ ] for slow completions, is there a way to load it asynchronously?
	- [ ] is there some easier way to install/cache part of the completions? i.e. could save result of `gh completion` except needs to invalidate cache on gh version change?


Different, but related to [predictors](https://learn.microsoft.com/en-us/powershell/scripting/learn/shell/using-predictors?view=powershell-7.4)
## gh
https://cli.github.com/manual/gh_completion#powershell

- [ ] each invocation of `gh completion -s powershell` seems to add extra 50ms to shell profile startup
```
$ timeit { pwsh -nop -c " gh completion -s powershell | out-null; gh completion -s powershell | out-null; gh completion -s powershell | out-null;  1+1" }
478.6222
349.3917
365.7026
359.771
$ timeit { pwsh -nop -c " gh completion -s powershell | out-null; gh completion -s powershell | out-null; 1+1" }
296.1812
304.4026
301.599
312.9825
$ timeit { pwsh -nop -c " gh completion -s powershell | out-null; 1+1" }
257.5467
249.5928
243.3354
254.3092
$ timeit { pwsh -nop -c " 1+1" }
204.3516
195.1117
189.3899
198.3138
```

- [ ] figure out perf problem, then add it

## rg
- [ ] https://github.com/BurntSushi/ripgrep/blob/master/FAQ.md#complete

## git
- [ ] I think posh-git adds completions; time how long adding that takes?

## General-purpose completion: `Register-ArgumentCompleter`
#ai-slop

[`Register-ArgumentCompleter`](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/register-argumentcompleter) is the general mechanism — not per-tool hacks. A completer is a scriptblock PowerShell invokes while you're typing; it can be attached to any command and run arbitrary logic at completion time.

```powershell
Register-ArgumentCompleter -Native -CommandName mytool -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
    # parse help output, return CompletionResult objects
    mytool --help | ... | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
```

Tools built with [Cobra](https://cobra.dev/), Click, Typer, Clap, etc. often expose machine-readable help — completers exploit that. This is how `kubectl`, `az`, `dotnet`, and `winget` feel "smart" without being hand-wired flag by flag.

### Crescendo: generate completers from schemas

[`Microsoft.PowerShell.Crescendo`](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.crescendo/) wraps native commands as PowerShell cmdlets with full parameter metadata, enabling tab completion and `Get-Help`. You define a JSON schema describing the command's parameters, and Crescendo generates the wrapper module.

- Best for: tools with stable, well-documented flag sets
- Limitation: you still have to author the schema; it doesn't auto-infer from `--help` text

### What doesn't exist yet

No universal "parse arbitrary `--help` text → semantic model → TUI picker mid-command" engine. Natural language help is too inconsistent. [Trogon](https://github.com/Textualize/trogon) (Python) gets close but only works because it targets CLIs built with known frameworks where the argument graph already exists as structured data — there's no equivalent AST for arbitrary external commands in PowerShell.

Practical hybrid today:
- PSReadLine for inline, mid-command prediction (history + context)
- Auto-generated `ArgumentCompleter`s for well-behaved tools
- On-demand pickers (`fzf`, `Out-GridView`) bound to key chords
