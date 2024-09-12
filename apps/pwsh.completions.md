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
