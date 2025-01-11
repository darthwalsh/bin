---
tags:
  - task-todo
---
Features that are required for me to find tool useful
- alternate files per device
- in a git repo
- *--nice to have cut line--*
- in same `bin\` git repo
- secret encryption/decryption
## Established tools
Summary: https://www.chezmoi.io/comparison-table/

### [GNU `stow`](https://www.gnu.org/software/stow/) is the OG
- its \*nix only
- [x] On #windows, does git-bash/WSL allow running this from a windows pwsh.exe shell?
    - sure, WSL can run anything
- [ ] Read manual, looking for features 🔼 
    - [ ] Import from [[Stow]]

### [`yadm`](https://github.com/TheLocehiliosan/yadm) is another tool
- [\*nix only](https://github.com/TheLocehiliosan/yadm/issues/363)
- https://yadm.io/docs/bootstrap script could i.e. run
	- brew install from `Brewfile`
	- `defaults write com.googlecode.iterm2 PrefsCustomFolder "$HOME/.iterm2"`
- [x] On #windows, does git-bash/WSL allow running this from a windows pwsh.exe shell? see [workaround](https://github.com/TheLocehiliosan/yadm/issues/363#issuecomment-973837636)
    - sure, WSL can run anything
- [ ] NEXT, see rewrite in https://github.com/jyfzh/PSYadm

- [ ] Read https://yadm.io/docs/alternates for different files on different systems. 🔼 
- [ ] NEXT, look at other features

### PSDotFiles
https://github.com/ralish/PSDotFiles
- Wants a componentized folder structure... kinda complicated?
- example usage: https://github.com/ralish/dotfiles

## Investigate: use bare git repo?

- [ ] this might conflate bare git repo and/or worktree. need to re-read the below
Bare git repos should avoid needing to use symlinks.
Instead of a tool to manage symlinks, could use a bare git repo?

- [ ] Read https://www.anand-iyer.com/blog/2018/a-simpler-way-to-manage-your-dotfiles/ 🔼 
- [ ] Also, https://mitxela.com/projects/dotfiles_management using `--work-tree=/`
- [ ] Usage: https://github.com/skx/dotfiles


Other tools that are interesting, read about:
- [ ] https://www.chezmoi.io/what-does-chezmoi-do/ 🔼 
- [ ] https://dotfiles.github.io/tutorials/
- [ ] https://www.chezmoi.io/why-use-chezmoi/
- [ ] https://github.com/arecarn/dploy
- [ ] https://github.com/jyf-111/PSYadm
- [ ] https://github.com/mattialancellotti/Stow
- [ ] https://github.com/paulirish/dotfiles/blob/main/symlink-setup.sh
- [ ] https://github.com/koenverburg/dotfiles/blob/c01299ac78f1d9b2bc63248f0f205d51550525c8/bin/windows/bootstrap.ps1
- [ ] https://www.anand-iyer.com/blog/2018/a-simpler-way-to-manage-your-dotfiles/
- [ ] https://medium.com/@mxcl/workbench-seamless-automatic-dotfile-sync-to-icloud-e5529e2d30a0
- [ ] https://github.com/lra/mackup
- [ ] https://shaky.sh/simple-dotfiles/
- [ ] https://github.com/zellwk/dotfiles
	- [ ] just loops over `.*` files, calling `ln -sf`
- [ ] https://github.com/ianthehenry/dotfiles/blob/master/init
	- [ ] looks over some `.files` and run `ln -s "$PWD/$file" "$HOME/$file"`
- [ ] https://github.com/mathiasbynens/dotfiles/blob/main/bootstrap.sh#L8
	- [ ] just rsyncs the git repo to `~`
- [ ] https://www.stefanjudis.com/notes/git-based-dotfile-management-without-symlinks/



Other example of dotfile contents to read:
- [ ] https://github.com/koenverburg/dotfiles
- [ ] https://github.com/anandpiyer/.dotfiles/tree/master/.dotfiles
	- [ ] ? Use karibiner elements to remap caps key to ESC or HYPER (CTRL + SHIFT + ALT)

