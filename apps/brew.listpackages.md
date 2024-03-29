## Getting the list of which packages are installed

*TL;DR:* `brew bundle dump --file=-`

See https://apple.stackexchange.com/questions/101090/list-of-all-packages-installed-using-homebrew which has various answers on this.

I want a script to be able to get the list of which [formulae and casks and taps](https://stackoverflow.com/a/46423275/771768) are installed. This will help in viewing the history of which apps I've installed, and setting up a new machine.

So, we want a machine-readable output from `brew`. 

These are the outputs of different CLI commands:

### list

`brew list -1` seems pretty good, but hold on, what's `libffi` in the output? That's just some dependency that I didn't install directly.

```
$ brew list -1
aom
aribb24
assimp
autoconf
bdw-gc
...
zimg
zstd
1password-cli
alt-tab
docker
...
```

*When piping to a program (not interactive terminal), it doesn't print the little label `==> Casks`*

### leaves

`brew leaves --installed-on-request` is better, but there's a known issue: It's [missing all casks](https://github.com/orgs/Homebrew/discussions/722).

```
$ brew leaves --installed-on-request
bfg
blakek/blakek/pomodoro
...
withgraphite/tap/graphite
xpdf
yarn
```

### deps

`brew deps -1 --installed` is interesting, as it shows the dependency graph for each package. But to see which packages were installed on request, we'd need to parse the dependency graph and find which aren't required? 

*(See also `--tree` and `--graph` for interesting visualizations.)*

```
$ brew deps -1 --installed
1password-cli: 
alt-tab: 
aom: jpeg-xl libvmaf
...
zimg: 
zstd: lz4 xz
```

### bundle

`brew bundle dump --file=- --describe` is the best so far, for representing what is on the machine. Using `--describe` gives nice comments to understand most packages.

```bash
$ brew bundle dump --file=- --describe
tap "1password/tap"
...
tap "withgraphite/tap"
# Core application library for C
brew "glib"
# Development kit for the Java programming language
brew "openjdk"
...
# macOS command line utility to configure multi-display resolutions and arrangements. Essentially XRandR for macOS.
brew "jakehilborn/jakehilborn/displayplacer"
# The Graphite CLI allows you to easily manage your stacked-diff workflow.
brew "withgraphite/tap/graphite"
# Command-line helper for the 1Password password manager
cask "1password-cli"
# Enable Windows-like alt-tab
cask "alt-tab"
```
