---
aliases:
    - homebrew
---
homebrew is a [[package manager]] for macOS (and also for linux, but expect to compile from source).
>[!WARNING] try using [[mise]]
>If an app supports xplat installation through mise, try that first. See [[package manager]]

## New machine setup
1. https://docs.brew.sh/Installation
2. Run `brew bundle` in the same folder as `Brewfile`
    - *ensure it is not downloaded as `.TXT` by github!*

## Autoupdate in the background
- [ ] `brew autoupdate stop; brew autoupdate delete; brew autoupdate start --upgrade --immediate --notify-on-error` 🔁 every 87 days 🏁 delete 📅 2026-09-23

* Upgrades all packages every 24 hours
* Docs: https://github.com/DomT4/homebrew-autoupdate?tab=readme-ov-file#usage
* Can view the config file: `less ~/Library/LaunchAgents/com.github.domt4.homebrew-autoupdate.plist`
* Shows stdout and stderr written to `~/Library/Logs/com.github.domt4.homebrew-autoupdate/com.github.domt4.homebrew-autoupdate.out`

* [ ] Consider adding to my profile: Don't wait during interactive shell sessions for updates
    * `export HOMEBREW_NO_AUTO_UPDATE=1`
### Recreate autoupdate before 90 days
Otherwise you get get message
>Autoupdate has been running for more than 90 days. Please consider periodically deleting and re-starting this command to ensure the latest features are enabled for you.
    - without delete, showed way years ago: `initialised on 2024-01-03. Delete and restart...`
### Notifications failing
Observed :
```
.../brew_autoupdate: line 11: 53810 Killed: 9               /opt/homebrew/bin/brew upgrade --no-ask --formula -v
brew-autoupdate notifier: could not request notification permission: Notifications are not allowed for this application
Warning: notifier failed to display the update result.
```

Workaround:
1. Register the app: `open /opt/homebrew/Library/Taps/domt4/homebrew-autoupdate/notifier/brew-autoupdate.app`
2. Relaunch `brew autoupdate` and wait (or fail the build by killing a ruby process)
3. *Now* `brew-autoupdate` appears in System Settings → Notifications: toggle on notifications

## Greedy cask upgrades

Casks with `auto_updates true` (Docker Desktop, Chrome, VS Code, Cursor, Discord, etc.) are skipped by normal `brew upgrade --cask`. The `--greedy` flag includes them, I guess updating all of them disrupts work.

Query which extra casks `--greedy` would pull in:
```bash
comm -13 \
    <(brew outdated --cask --quiet | sort) \
    <(brew outdated --cask --greedy --quiet | sort)
```

To opt-in greedy for specific casks only, use [`HOMEBREW_UPGRADE_GREEDY_CASKS`](https://docs.brew.sh/Manpage) (space-separated list), and *then don't use `--greedy`*:

```bash
export HOMEBREW_UPGRADE_GREEDY_CASKS="docker-desktop"
```

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

## Preventing Supply-Chain Attacks
- [ ] Read [Homebrew Documentation: Software Supply Chain Security](https://docs.brew.sh/Supply-Chain-Security)

- [ ] Look for something like [`install_before = "7d"`](https://mise.jdx.dev/tips-and-tricks.html#minimum-release-age) in [[mise#Supply-chain hardening `install_before`]]

## Alternatives
I was considering moving to [`tea`/`pkgx`](tea.md).

Cool features:

- symlink `jq -> tea` and it would automagically download then run i.e. `jq` on-demand
- setting up zsh shell's (or pwsh?) command-not-found function to install from tea

...but brew seems much more stable for now.
- [ ] Something to look into later 🛫 2025-01-01

## Fix "`brew install ...` process has already locked"

```
Error: A `brew install pkgx` process has already locked /opt/homebrew/Cellar/ca-certificates.
Please wait for it to finish or terminate it to continue.
```
Ensure no other brew running, then run:
- [ ] Not sure about how to detect [[#Autoupdate in the background]]
```
rm -rf "$(brew --prefix)/var/homebrew/locks"
```

## Where files land

Formulae install under `$(brew --prefix)/Cellar/<name>/<version>`, symlinked onto `PATH`. Casks drop `.app` directly into `/Applications` — same as a drag-install. See [[package.files]].
