---
aliases:
  - wt
---
[Worktrunk](https://worktrunk.dev/worktrunk/) is a great CLI/TUI for switching [[git]] worktrees: 

You can run:
```bash
wt switch -c -x claude feat -- 'Add user auth'
#equals
git worktree add -b feat ../repo.feat
cd ../repo.feat
claude 'Add user auth'

wt remove
# equals
cd ../repo
git worktree remove ../repo.feat
git branch -d feat

wt switch pr:337
# equals
git worktree add ../repo.feat
cd ../repo.feat
gh pr checkout 337
```
*doesn't seem to have TUI like `gh pr checkout` but that's ok!*

- [x] Read [Tips & Patterns \| Worktrunk](https://worktrunk.dev/tips-patterns/) and there's lots of features I'd use! 
## Switch Shortcuts

| Shortcut | Meaning                            |
| -------- | ---------------------------------- |
| `^`      | Default branch (`main` / `master`) |
| `@`      | Current branch/worktree            |
| `-`      | Previous worktree (like `cd -`)    |
| `pr:{N}` | GitHub PR #N's branch              |
### Submodule Checkout
In `.worktrunk.yaml` config added.
Considered moving`git` to `post-switch` (async might be messy) but instead `rsync`ing files into the worktree.

### Copying Cache
- [ ] [`wt step copy-ignored`](https://worktrunk.dev/step/#wt-step-copy-ignored) to copy `.env`
- [ ] will it work to copy [[uv]] venv?  Or, run `setup-uv.sh` in `post-start`

## pre-commit hook
Not useful to me!
Doesn't seem to nice features of [[pre-commit]] framework, which can run `ty` only on PY changes.

## Hashed port
- [ ] template filter `open http://localhost:{{ branch | hash_port }}`
- [ ] [`wt step tether`](https://worktrunk.dev/step/#wt-step-tether) will run a command; killed when wt is removed

## Merge
`wt merge [other-branch] [--no-squash]` squash merges current branch onto default/target branch and removes current worktree.

Can use [LLM commit messages](https://worktrunk.dev/config/#llm-commit-messages) auto-configuring [[claude-code]], etc.
Supports `template-append` for team-wide conventions (conventional commits, Jira refs).
Alternatively, could configure [manual commit messages](https://worktrunk.dev/tips-patterns/#manual-commit-messages).

## List
- [ ] Look into LLM integration https://worktrunk.dev/list/#full-mode
- [ ] Look into CI integration: `wt list --full --branches` is like [[github.pr.dash]], see [symbols](https://worktrunk.dev/list/#status-symbols)

## Persist environment
- `wt config state vars set env=staging`, then `{{ vars.env | default('dev') }}` in hooks
- [ ] use this to persist per-worktree dev-script CLI args (e.g. `intreq stg-svc`, `mck stg`) that are currently lost when `actt` auto-sources scripts bare

## JSON API
```
wt list --format=json
```
Some examples: [JSON output](https://worktrunk.dev/list/#json-output)

## Default branch
Could replace [[Get-GitDefaultBranch.ps1]]:
```
git rebase $(wt config state default-branch)
```
- [ ] bug with pwsh plugin though, where `wt config` prints an extra `0` to stdout...:
```
$ ~/.local/share/mise/shims/wt config state default-branch
develop

$ wt config state default-branch
develop
0
```
