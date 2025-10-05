---
aliases:
  - homebrew
---
homebrew is a [[package manager]] for macOS (and also for linux, but expect to compile from source).
## New machine setup
1. https://docs.brew.sh/Installation
2. Run `brew bundle` in the same folder as `Brewfile`
  - *ensure it is not downloaded as `.TXT` by github!*

## Autoupdate in the background

- Run `brew autoupdate start --upgrade --immediate`
  * Upgrades all packages every 24 hours
  * Docs: https://github.com/DomT4/homebrew-autoupdate?tab=readme-ov-file#usage
  * Can view the config file: `less ~/Library/LaunchAgents/com.github.domt4.homebrew-autoupdate.plist`
  * Shows stdout and stderr written to `~/Library/Logs/com.github.domt4.homebrew-autoupdate/com.github.domt4.homebrew-autoupdate.out`
* Ensure homebrew-updater has Notification permission in System Preferences
* Don't wait during interactive shell sessions for updates
  * `export HOMEBREW_NO_AUTO_UPDATE=1`

Will get message
>Autoupdate has been running for more than 90 days. Please consider periodically deleting and re-starting this command to ensure the latest features are enabled for you.
- [ ] `brew autoupdate stop; brew autoupdate start --upgrade --immediate` 🔁 every 90 days 🏁 delete 📅 2025-12-27
## Cleanup
- Don't need to clean up manually, just don't change default:
  * `brew cleanup` will run automatically every 30 days
* Auto-Remove dependencies that are not long needed after running `brew autoremove`
  * Now the default, will run automatically every cleanup and uninstall
  * Before [brew 4.3.0](https://github.com/Homebrew/brew/releases/tag/4.3.0) needed to opt-in by setting `export HOMEBREW_AUTOREMOVE=1`
* Removing taps
  * I documented my workaround here: https://superuser.com/questions/1778642/how-to-untap-all-unused-brew-taps
  * Don't feel like I have a good answer yet, because it's good to untap `cask` but bad to untap `bundle`...

## Getting the list of which packages are installed
[[brew.listpackages]]
Wrote script [`brewdump`](../brewdump.ps1) to output the packages [back into the git repo](Brewfile).
## Sharing your brewfiles

Run `npx share-brewfiles`

My profile: https://www.brewfiles.com/brew/sl1tf2ImZ4RucCebCSg6/

## Alternatives
I was considering moving to [`tea`/`pkgx`](tea.md).

Cool features:

- symlink `jq -> tea` and it would automagically download then run i.e. `jq` on-demand
- setting up zsh shell's (or pwsh?) command-not-found function to install from tea

...but brew seems much more stable for now.
- [ ] Something to look into later 🛫 2025-01-01
