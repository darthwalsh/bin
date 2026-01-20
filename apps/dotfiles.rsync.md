Set up dotfiles on a new server or docker container using `rsync` to pull files
```
tmp="$(mktemp -d)" && rsync -a --exclude='.ssh' user@host:~/.[!.]* "$tmp"/ && HOME="$tmp" exec "$SHELL"
```
- [ ] Might be easier to just `git clone` the repo instead of rsync...
- [ ] Try for [[dsh.ps1]] (i.e. mounting both [[dotfiles]], then `bin/` into `$PATH` )
- [ ] For SSH, might want to use `rsync` from macbook instead
