---
tags:
  - app-idea
---
- [ ] git commit fail on `TODO |TODONT` text being added? Could I make this a global pre commit hook? 
- [ ] Would I be able to stop running `gitodo.ps1`?
	- [ ] That has special logic to check files not staged, but precommit hook makes that simpler

## Existing tools
- [x] search google for prior art
https://github.com/pimterry/git-confirm has bash script runs local `grep`, and interactively prompt when pattern matches
- [x] NEXT, claims it works in powershell but try it on #windows  -- not sure how that's possible outside WSL, using regular bash 🔼

```command
$ git config --add hooks.confirm.match "TODO "  
$ git config --add hooks.confirm.match "TODONT"  
$ git config --get-all hooks.confirm.match  
TODO  
TODONT
```

- [ ] Check this doesn't hang vscode git commit on prompt

### Git-for-Windows has special logic to run `git-bash` on hooks
Just start hook with `#!/bin/sh`
See https://github.com/git-for-windows/git/issues/1420#issuecomment-355433179

- [-] kind of old project, should be simple to recreate xplat, like a powershell version of ❌ 2024-10-22
	- https://stackoverflow.com/a/7292992/771768
	- https://stackoverflow.com/a/40510130/771768


## Global git hook, that doesn't break local pre-commit
It would be nice to have a global git hook to run this on all repos, [i.e. this](https://stackoverflow.com/a/37293198/771768):

```command
git config --global core.hooksPath /path/to/my/centralized/hooks
```
BUT!
>setting a global hooks path disables all local hooks in your repos!

- [ ] Simple example: create run-local-hook global script like https://stackoverflow.com/a/71939092/771768 #macbook ⏫
- [ ] fallback, maybe local git config of core.hooksPath ignores this on pre-commit repos

### Add secret scanning without stomping `pre-commit`
Use a different hook slot (`prepare-commit-msg`) so the Python `pre-commit` framework keeps the `pre-commit` hook.

- Install scanner once: `brew install gitleaks`
- Put this in `~/.githooks/prepare-commit-msg-gitleaks` and `chmod +x`:
```bash
#!/bin/bash

set -euo pipefail

# Bail on merge/squash templates; only scan real commits
case "$2" in
  message|template|"") ;;
  *) exit 0 ;;
esac

gitleaks protect --staged --verbose
```

- To activate in a repo (does not touch `pre-commit`): copy or symlink into `.git/hooks/prepare-commit-msg`.
  - Example: `ln -s ~/.githooks/prepare-commit-msg-gitleaks .git/hooks/prepare-commit-msg`
- Optional bypass for noisy repos: `git commit --no-verify`

If `prepare-commit-msg` is already in use, same idea works in `commit-msg` (still separate from `pre-commit`).
