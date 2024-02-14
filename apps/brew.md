## New machine setup
https://docs.brew.sh/Installation
Run `brew bundle` in the same folder as `Brewfile` (not .TXT)
## Autoupdate in the background

- Run `brew autoupdate start --upgrade --immediate`
  * Upgrades all packages every 24 hours
  * https://docs.brew.sh/Manpage#autoupdate-subcommand-interval-options
  * Can view the config file: `less ~/Library/LaunchAgents/com.github.domt4.homebrew-autoupdate.plist`
* Ensure homebrew-updater has Notification permission in System Preferences
* In your shell profile: `export HOMEBREW_AUTOREMOVE=1`
  * skip interactively updating


## Cleanup
- Don't need to clean up manually, just don't change default:
  * `brew cleanup` Will run automatically every 30 days
* In your shell profile: `export HOMEBREW_AUTOREMOVE=1`
  * Deletes deps that are no longer needed by automatically running `brew autoremove`
  * will run automatically every cleanup and uninstall
* Removing taps
  * I documented my workaround here: https://superuser.com/questions/1778642/how-to-untap-all-unused-brew-taps
  * Don't feel like I have a good answer yet, because it's good to untap `cask` but bad to untap `bundle`...

## Getting the list of which packages are installed
[[brew.listpackages]]

## Alternatives
I was considering moving to [`tea`/`pkgx`](tea.md) (I really liked the feature where you can symlink `jq -> tea` and it would automagically download then run the package. Also, setting up the zsh shell's (or pwsh?) command-not-found function to install from tea

...but brew seems much more stable for now.
- [ ] Something to look into in 2025?
