By default `git stash` will include both working tree and index files. (Same with vscode command  "Git: Stash")

In order to also stash *untracked* files, use option `git stash --include-untracked` which has alias `-u`.

> [!WARNING] Do not use `--all` or `-a`
> it will ***delete some untracked files***, [at least in 2012](https://web.archive.org/web/20140310215100/http://blog.icefusion.co.uk:80/git-stash-can-delete-ignored-files-git-stash-u/)

There is also option `--keep-index` to prevent the index from changing. (It's like `git stash; git stash apply`.) No option to keep the working files.

If you run `git stash show --patch` you won't see any unchanged files by default `stash.showIncludeUntracked` . Instead run `git stash show --include-untracked --patch` (alias `-up`).
