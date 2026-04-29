From https://stackoverflow.com/a/22906950/771768
1. `.gitignore` applies to every clone of this repository (versioned, everyone will have it)
2. `.git/info/exclude` only applies to your local copy of this repository (local, not shared with others)
3. `~/.gitignore` with config `core.excludesfile=~/.gitignore` applies to all the repositories on your computer (local, not shared with others
4. `git update-index --skip-worktree <file>` skips some file from being committed
