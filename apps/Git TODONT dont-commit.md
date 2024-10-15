---
tags:
  - app-idea
---
- [ ] git commit fail on `TODO |TODONT` text being added? Could I make this a global pre commit hook? ⏫ 
- [ ] Would I be able to stop running `gitodo.ps1`?
	- [ ] That has special logic to check files not staged, but precommit hook makes that simpler

## Existing tools
- [x] search google for prior art
https://github.com/pimterry/git-confirm has bash script runs local `grep`, and interactively prompt when pattern matches
- [ ] NEXT, claims it works in powershell but try it on #windows  -- not sure how that's possible outside WSL, using regular bash 🔼 
- [ ] kind of old project, should be simple to recreate xplat, like a powershell version of 
	- https://stackoverflow.com/a/7292992/771768
	- https://stackoverflow.com/a/40510130/771768

## git commit hook

## Global git hook, that doesn't break local pre-commit
It would be nice to have a global git hook to run this on all repos, [i.e. this](https://stackoverflow.com/a/37293198/771768):

```command
git config --global core.hooksPath /path/to/my/centralized/hooks
```
BUT!
>setting a global hooks path disables all local hooks in your repos!

- [ ] Simple example: create local script like https://stackoverflow.com/a/71939092/771768
- [ ] fallback, maybe local git config hooks path back to local script
